local root

local function set_fail()
	root.fail = root
	local queue = {root}
	while #queue > 0 do
		local node = table.remove(queue,1)
		for index,new_node in pairs(node) do
			if type(index) == "number" then
				if node == root then
					new_node.fail = root
				else
					local fail = node.fail
					while fail ~= root and not fail[index] do
						fail = fail.fail
					end
					new_node.fail = fail[index] or root
				end
				if new_node.fail.leaf and not new_node.leaf then
					new_node.leaf = new_node.fail.leaf
				end
				table.insert(queue,new_node)
			end
		end
	end
end

local function init_tree(words)
	root = {}
	for _,word in ipairs(words) do
		local node = root
		for _,ch in utf8.codes(word) do
			node[ch] = node[ch] or {}
			node = node[ch]
		end
		node.leaf = utf8.len(word)
	end
end

local function trie_find(str)
	local keywords = {}
	
	local node = root
	for index,ch in utf8.codes(str) do
		while node ~= root and not node[ch] do
			node = node.fail
		end
		node = node[ch] or root
		if node.leaf then
			table.insert(keywords,index - node.leaf + 1)
			table.insert(keywords,index)
		end
	end
	
	return keywords
end

local function filter(str)
	local keywords = trie_find(str)
	if #keywords > 0 then
		local length = utf8.len(str)
		local sentence = table.pack(utf8.codepoint(str,1,length))
		for index = 1, #keywords, 2 do
			local start = keywords[index]
			local stop = keywords[index+1]
			for i = start,stop do
				sentence[i] = 42 -- ascii('*') = 42
			end
		end
		return utf8.char(table.unpack(sentence))
	else
		return str
	end
end

local words = {}
for l in io.lines("wordlist.txt") do
	table.insert(words,l)
end
	
init_tree(words)
set_fail()

print(filter("abcdefasd"))

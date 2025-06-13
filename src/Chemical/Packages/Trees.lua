-- Tree Library == Vibe coded by Sovereignty

export type Node<value = any> = {
	Key: string,
	Value: value,
	Children: {Node<value>},
	Parent: Node<value>?,
	FullPath: string,

	new: (key: string, value: any?) -> Node<value>,
	AddChild: (self: Node<value>, key: string, value: any?) -> Node<value>,
	GetChild: (self: Node<value>, key: string) -> Node<value>?,
	GetChildren: (self: Node<value>) -> {Node<value>},
	GetAllDescendants: (self: Node<value>) -> {Node<value>},
	GetPath: (self: Node<value>) -> {string},
	SetValue: (self: Node<value>, value: any?) -> (),
	TraverseDFS: (self: Node<value>, callback: (node: Node<value>) -> ()) -> (),
	TraverseBFS: (self: Node<value>, callback: (node: Node<value>) -> ()) -> (),
}

export type Tree<nodeValue = any> = {
	Root: Node<nodeValue>,

	new: (rootKey: string?, rootValue: any?) -> (Tree<nodeValue>),
	AddNode: (self: Tree<nodeValue>, pathParts: {string}, value: any?) -> Node<nodeValue>,
	GetNode: (self: Tree<nodeValue>, pathParts: {string}) -> Node<nodeValue>?,
	GetNodeChildrenByPath: (self: Tree<nodeValue>, pathParts: {string}) -> {Node<nodeValue>},
	GetDescendantsByPath: (self: Tree<nodeValue>, pathParts: {string}) -> {Node<nodeValue>},
	FindNode: (self: Tree<nodeValue>, predicate: (node: Node<nodeValue>) -> boolean) -> Node<nodeValue>?,
	RemoveNode: (self: Tree<nodeValue>, pathParts: {string}) -> boolean,
	UpdateNode: (self: Tree<nodeValue>, pathParts: {string}, newValue: any) -> boolean,
	GetPathString: (self: Tree<nodeValue>, pathParts: {string}) -> string,
	Traverse: (self: Tree<nodeValue>, method: "DFS" | "BFS", callback: (node: Node<nodeValue>) -> ()) -> (),
	Print: (self: Tree<nodeValue>) -> (),
}

local Node = {} :: Node
Node.__index = Node

function Node.new(key: string, value: any?): Node
	return setmetatable({
		Key = key,
		Value = value,
		Children = {} :: {Node},
		Parent = nil :: Node?,
		FullPath = ""
	}, Node) :: any
end

function Node:AddChild(key: string, value: any?): Node
	local child = Node.new(key, value)
	child.Parent = self

	if self.FullPath == "/" then
		child.FullPath = "/" .. key
	else
		child.FullPath = self.FullPath .. "/" .. key
	end

	table.insert(self.Children, child)
	return child
end

function Node:GetChild(key: string): Node?
	for _, child in ipairs(self.Children) do
		if child.Key == key then
			return child
		end
	end
	return nil
end

function Node:GetChildren(): {Node}
	return self.Children
end

function Node:GetAllDescendants(): {Node}
	local descendants = {} :: {Node}
	local function traverse(node: Node)
		for _, child in ipairs(node.Children) do
			table.insert(descendants, child)
			traverse(child)
		end
	end
	traverse(self)
	return descendants
end

function Node:GetPath(): {string}
	local parts = {} :: {string}
	local current: Node? = self
	while current do
		table.insert(parts, 1, current.Key)
		current = current.Parent
	end
	return parts
end

function Node:SetValue(value: any?)
	self.Value = value
end

function Node:TraverseDFS(callback: (node: Node) -> ())
	callback(self)
	for _, child in ipairs(self.Children) do
		child:TraverseDFS(callback)
	end
end

function Node:TraverseBFS(callback: (node: Node) -> ())
	local queue = {self} :: {Node}
	while #queue > 0 do
		local current = table.remove(queue, 1)
		callback(current)
		for _, child in ipairs(current.Children) do
			table.insert(queue, child)
		end
	end
end

local Tree = {} :: Tree
Tree.__index = Tree

function Tree.new(rootKey: string?, rootValue: any?): Tree
	local rootKey = rootKey or "/"
	local root = Node.new(rootKey, rootValue)

	root.FullPath = rootKey == "/" and "/" or "/" .. rootKey

	return setmetatable({
		Root = root
	}, Tree) :: Tree
end

function Tree:AddNode(pathParts: {string}, value: any?): Node
	local current: Node = self.Root

	for _, part in ipairs(pathParts) do
		local child = current:GetChild(part)

		if not child then
			child = current:AddChild(part, nil)
		end

		current = child
	end

	current.Value = value
	return current
end

function Tree:GetNode(pathParts: {string}): Node?
	local current: Node? = self.Root
	for _, part in ipairs(pathParts) do
		local nextNode = current:GetChild(part)
		if not nextNode then break end
		current = nextNode
	end
	return current ~= self.Root and current
end

function Tree:GetNodeChildrenByPath(pathParts: {string}): {Node}
	local node = self:GetNode(pathParts)
	return node and node:GetChildren() or {}
end

function Tree:GetDescendantsByPath(pathParts: {string}): {Node}
	local node = self:GetNode(pathParts)
	return node and node:GetAllDescendants() or {}
end

function Tree:FindNode(predicate: (node: Node) -> boolean): Node?
	local found: Node? = nil
	self.Root:TraverseDFS(function(node)
		if predicate(node) then
			found = node
		end
	end)
	return found
end

function Tree:RemoveNode(pathParts: {string}): boolean
	local node = self:GetNode(pathParts)
	if not node or node == self.Root then return false end

	local parent = node.Parent
	if not parent then return false end

	for i, child in ipairs(parent.Children) do
		if child == node then
			table.remove(parent.Children, i)
			return true
		end
	end

	return false
end

function Tree:UpdateNode(pathParts: {string}, newValue: any): boolean
	local node = self:GetNode(pathParts)
	if node then
		node.Value = newValue
		return true
	end
	return false
end

function Tree:GetPathString(pathParts: {string}): string
	return "/" .. table.concat(pathParts, "/")
end

function Tree:Traverse(method: "DFS" | "BFS", callback: (node: Node) -> ())
	if method == "DFS" then
		self.Root:TraverseDFS(callback)
	elseif method == "BFS" then
		self.Root:TraverseBFS(callback)
	else
		error("Invalid traversal method. Use 'DFS' or 'BFS'")
	end
end

function Tree:Print()
	print("Tree Structure:")
	self.Root:TraverseDFS(function(node)
		local indent = string.rep("  ", #node:GetPath() - 1)

		-- Fix: Format root path correctly
		local displayPath = node.FullPath
		if node == self.Root and node.Key == "/" then
			displayPath = "/"
		end

		print(indent .. node.Key .. " (" .. displayPath .. ")")
	end)
end

return Tree
local listClass, linkClass = {}, {}
listClass.__index, linkClass.__index = listClass, linkClass

export type List<T> = typeof(listClass.new((1 :: any) :: T))

function listClass.new()
	local self = setmetatable({}, listClass)
	self.List = self
	self.Links = {}
	self.Length = 0
	self.Next = self
	self.Previous = self
	return self
end

function listClass:InsertFront(value)
	assert(self.Links[value] == nil, "Value already exists")
	local link = {Value = value, List = self, Previous = self, Next = self.Next}
	self.Links[value] = link
	self.Length += 1
	self.Next.Previous = link
	self.Next = link
	return setmetatable(link, linkClass)
end

function listClass:InsertAfter(value)
	assert(self.Links[value] == nil, "Value already exists")
	local link = {Value = value, List = self, Previous = self, Next = self.Next}
	self.Links[value] = link
	self.Length += 1
	self.Next.Previous = link
	self.Next = link
	return setmetatable(link, linkClass)
end

function listClass:InsertBack(value)
	assert(self.Links[value] == nil, "Value already exists")
	local link = {Value = value, List = self, Next = self, Previous = self.Previous}
	self.Links[value] = link
	self.Length += 1
	self.Previous.Next = link
	self.Previous = link
	return setmetatable(link, linkClass)
end

function listClass:InsertBefore(value)
	assert(self.Links[value] == nil, "Value already exists")
	local link = {Value = value, List = self, Next = self, Previous = self.Previous}
	self.Links[value] = link
	self.Length += 1
	self.Previous.Next = link
	self.Previous = link
	return setmetatable(link, linkClass)
end

function listClass:GetNext(link)
	link = (link or self).Next
	if link ~= self then return link, link.Value end
end

function listClass:GetPrevious(link)
	link = (link or self).Previous
	if link ~= self then return link, link.Value end
end

function listClass:IterateForward(link)
	return listClass.GetNext, self, link
end

function listClass:IterateBackward(link)
	return listClass.GetPrevious, self, link
end

function listClass:Remove(value, clean: boolean?)
	local link = self.Links[value]
	if link ~= nil then
		self.Links[value] = nil
		self.Length -= 1
		link.List = nil
		link.Previous.Next = link.Next
		link.Next.Previous = link.Previous
		
		if clean then setmetatable(link, nil) return end
		return link
	end
end

function listClass:RemoveFirst()
	local link = self.Next
	if link ~= self then
		self.Links[link.Value] = nil
		self.Length -= 1
		link.List = nil
		link.Previous.Next = link.Next
		link.Next.Previous = link.Previous
		return link.Value, link
	end
end

function listClass:RemoveLast()
	local link = self.Previous
	if link ~= self then
		self.Links[link.Value] = nil
		self.Length -= 1
		link.List = nil
		link.Previous.Next = link.Next
		link.Next.Previous = link.Previous
		return link.Value, link
	end
end

function listClass:Destroy()
	local l = self.List.Length
	for link, value in self:IterateForward() do
		self:Remove(value, true)
	end
	setmetatable(self, nil)
	table.clear(self)
end

function linkClass:InsertAfter(value)
	assert(self.List.Links[value] == nil, "Value already exists")
	local link = {Value = value, List = self.List, Previous = self, Next = self.Next}
	self.List.Links[value] = link
	self.List.Length += 1
	self.Next.Previous = link
	self.Next = link
	return setmetatable(link, linkClass)
end

function linkClass:InsertBefore(value)
	assert(self.List.Links[value] == nil, "Value already exists")
	local link = {Value = value, List = self.List, Next = self, Previous = self.Previous}
	self.List.Links[value] = link
	self.List.Length += 1
	self.Previous.Next = link
	self.Previous = link
	return setmetatable(link, linkClass)
end

function linkClass:GetNext()
	local link = self.Next
	if link ~= link.List then return link end
end

function linkClass:GetPrevious()
	local link = self.Previous
	if link ~= link.List then return link end
end

function linkClass:Remove()
	assert(self.List ~= nil, "Link is not in a list")
	self.List.Links[self.Value] = nil
	self.List.Length -= 1
	self.List = nil
	self.Previous.Next = self.Next
	self.Next.Previous = self.Previous
end

return listClass
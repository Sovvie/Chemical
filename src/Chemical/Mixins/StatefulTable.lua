--!strict

local RootFolder = script.Parent.Parent

local Cache = require(RootFolder.Cache)
local ECS = require(RootFolder.ECS)
local Types = require(RootFolder.Types)

export type StatefulTable<T = {}> = Types.HasEntity & {
	insert: <V>(self: StatefulTable<T>, value: V) -> (),
	remove: <V>(self: StatefulTable<T>, value: V) -> (),
	find: <V>(self: StatefulTable<T>, value: V) -> (number)?,
	
	setAt: <V>(self: StatefulTable<T>, index: number, value: V) -> (),
	getAt: (self: StatefulTable<T>, index: number) -> (any?),
	
	clear: (self: StatefulTable<T>) -> (),
}

return {
	insert = function<T>(self: StatefulTable, value: T)
		local tbl = ECS.World:get(self.entity, ECS.Components.Value)
		local newTbl = table.clone(tbl)
		
		table.insert(newTbl, value)
		
		ECS.World:set(self.entity, ECS.Components.Value, newTbl)
	end,

	remove = function<T>(self: StatefulTable, value: T)
		local tbl = ECS.World:get(self.entity, ECS.Components.Value)
		local newTbl = table.clone(tbl)
		
		local index = table.find(newTbl, value)
		local poppedValue = table.remove(newTbl, index)
		
		ECS.World:set(self.entity, ECS.Components.Value, newTbl)
		
		return poppedValue
	end,
	
	find = function<T>(self: StatefulTable, value: T)
		local tbl = ECS.World:get(self.entity, ECS.Components.Value)
		local found = table.find(tbl, value)

		return found
	end,

	setAt = function<T>(self: StatefulTable, index: number, value: T)
		local tbl = ECS.World:get(self.entity, ECS.Components.Value)
		local newTbl = table.clone(tbl)
		
		newTbl[index] = value
		
		ECS.World:set(self.entity, ECS.Components.Value, newTbl)
	end,
	
	getAt = function(self: StatefulTable, index: number)
		local tbl = ECS.World:get(self.entity, ECS.Components.Value)
		return tbl[index]
	end,
	
	clear = function(self: StatefulTable)
		local tbl = ECS.World:get(self.entity, ECS.Components.Value)
		local newTbl = table.clone(tbl)
		
		table.clear(newTbl)
		
		ECS.World:set(self.entity, ECS.Components.Value, newTbl)
	end,
}

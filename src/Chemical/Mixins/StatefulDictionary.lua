--!strict

local RootFolder = script.Parent.Parent

local Cache = require(RootFolder.Cache)
local ECS = require(RootFolder.ECS)
local Types = require(RootFolder.Types)

local Destroy = require(RootFolder.Functions:FindFirstChild("Destroy"))

export type StatefulDictionary<T = {}> = Types.HasEntity & {
	key: <K, V>(self: StatefulDictionary<T>, key: K, value: V?) -> (),
	clear: <V>(self: StatefulDictionary<T>, cleanup: (value: V) -> ()?) -> (any?),
}

local function recursive(tbl, func)
	for key, value in tbl do
		if typeof(value) == "table" and not value.type then
			recursive(value, func)
			
			continue
		end
		
		func(value)
	end
end

return {
	key = function<T, V>(self: StatefulDictionary, key: T, value: V?)
		local tbl = ECS.World:get(self.entity, ECS.Components.Value)
		local newTbl = table.clone(tbl)
		
		newTbl[key] = value
		
		ECS.World:set(self.entity, ECS.Components.Value, newTbl)
	end,

	clear = function(self: StatefulDictionary, cleanup: (any) -> ())
		local tbl = ECS.World:get(self.entity, ECS.Components.Value)
		local newTbl = table.clone(tbl)
		
		if cleanup then
			recursive(newTbl, cleanup)
		end
		
		newTbl = {}
		
		ECS.World:set(self.entity, ECS.Components.Value, newTbl)

	end,

}

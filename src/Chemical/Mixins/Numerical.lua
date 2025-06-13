--!strict

local RootFolder = script.Parent.Parent

local Cache = require(RootFolder.Cache)
local ECS = require(RootFolder.ECS)
local Types = require(RootFolder.Types)

export type Numerical = Types.HasEntity & {
	increment: (self: Numerical, n: number) -> (),
	decrement: (self: Numerical, n: number) -> ()
}

return {
	increment = function(self: Numerical, n: number)
		local cachedValue = ECS.World:get(self.entity, ECS.Components.Value)

		ECS.World:set(self.entity, ECS.Components.PrevValue, cachedValue)
		ECS.World:set(self.entity, ECS.Components.Value, cachedValue + n)
	end,
	
	decrement = function(self: Numerical, n: number)
		local cachedValue = ECS.World:get(self.entity, ECS.Components.Value)

		ECS.World:set(self.entity, ECS.Components.PrevValue, cachedValue)
		ECS.World:set(self.entity, ECS.Components.Value, cachedValue - n)
	end,
}

--!strict

local RootFolder = script.Parent.Parent

local Cache = require(RootFolder.Cache)
local ECS = require(RootFolder.ECS)
local Types = require(RootFolder.Types)

export type Settable<T = any> = Types.HasEntity & {
	set: (self: Settable<T>, T) -> ()
}

return {
	set = function(self: Settable, value: any)
		local cachedValue = ECS.World:get(self.entity, ECS.Components.Value)
		
		if value == cachedValue then
			return
		end
		
		ECS.World:set(self.entity, ECS.Components.PrevValue, cachedValue)
		ECS.World:set(self.entity, ECS.Components.Value, value)
	end,
}

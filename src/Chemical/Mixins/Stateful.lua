--!strict

local RootFolder = script.Parent.Parent

local Cache = require(RootFolder.Cache)
local ECS = require(RootFolder.ECS)
local Types = require(RootFolder.Types)

export type Stateful<T = any> = Types.HasEntity & {
	get: (self: Stateful<T>) -> (T)
}

return {
	get = function(self: Stateful)
		local withinEntity = Cache.Stack:Top()
		if withinEntity then
			ECS.World:add(withinEntity, ECS.JECS.pair(ECS.Tags.SubscribesTo, self.entity))
			ECS.World:add(self.entity, ECS.JECS.pair(ECS.Tags.HasSubscriber, withinEntity))
		end

		return ECS.World:get(self.entity, ECS.Components.Value)
	end,
}

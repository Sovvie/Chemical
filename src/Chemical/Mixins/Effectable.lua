--!strict
local RootFolder = script.Parent.Parent
local ECS = require(RootFolder.ECS)
local Cache = require(RootFolder.Cache)
local Types = require(RootFolder.Types)

export type Effectable = Types.HasEntity & {
	run: (self: Effectable) -> (),
}

return {
	run = function(self: Effectable)
		local effectFn = ECS.World:get(self.entity, ECS.Components.EffectFn)
		if not effectFn then return end


		local oldCleanupFn = ECS.World:get(self.entity, ECS.Components.CleanupFn)
		if oldCleanupFn then
			oldCleanupFn()
			
			
			ECS.World:remove(self.entity, ECS.Components.CleanupFn)
		end

		Cache.Stack:Push(self.entity)
		local newCleanupFn = effectFn()
		Cache.Stack:Pop()

		if newCleanupFn then
			ECS.World:set(self.entity, ECS.Components.CleanupFn, newCleanupFn)
		end
	end,
}
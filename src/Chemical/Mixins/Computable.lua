--!strict

local RootFolder = script.Parent.Parent

local ECS = require(RootFolder.ECS)
local Cache = require(RootFolder.Cache)
local Types = require(RootFolder.Types)

local GetSubscribers = require(RootFolder.Functions.GetSubscribers)

export type Computable<T = any> = Types.HasEntity & {
	compute: (self: Computable<T>) -> (),
}

type MaybeCleanable = {
	clean: (self: MaybeCleanable) -> ()
}

return {
	compute = function(self: Computable & MaybeCleanable)
		local computeFn = ECS.World:get(self.entity, ECS.Components.ComputeFn)
		if not computeFn then return end
		
		
		local oldValue = ECS.World:get(self.entity, ECS.Components.Value)
		local cleanupFn = ECS.World:get(self.entity, ECS.Components.CleanupFn)
		
		if oldValue and cleanupFn then
			cleanupFn(oldValue)
		end

		Cache.Stack:Push(self.entity)
		local s, result = pcall(computeFn)
		Cache.Stack:Pop()

		if not s then
			warn("Chemical Computed Error: ", result)
			return
		end

		if result ~= oldValue then
			ECS.World:set(self.entity, ECS.Components.PrevValue, oldValue)
			ECS.World:set(self.entity, ECS.Components.Value, result)

			local subscribers = GetSubscribers(self.entity)
			for _, subscriberEntity in ipairs(subscribers) do
				if not ECS.World:has(subscriberEntity, ECS.Tags.IsDirty) then
					ECS.World:add(subscriberEntity, ECS.Tags.IsDirty)
				end
			end
		end
	end,
}
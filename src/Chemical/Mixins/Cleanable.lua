--!strict

local RootFolder = script.Parent.Parent

local ECS = require(RootFolder.ECS)
local Types = require(RootFolder.Types)

export type Cleanable = Types.HasEntity & {
	clean: (self: Cleanable) -> (),
}

return {
	clean = function(self: Cleanable)
		local cleanupFn = ECS.World:get(self.entity, ECS.Components.CleanupFn)
		if cleanupFn then
			cleanupFn()
		end
	end,
}
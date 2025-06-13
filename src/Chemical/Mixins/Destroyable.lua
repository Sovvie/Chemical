--!strict

local RootFolder = script.Parent.Parent

local Types = require(RootFolder.Types)
local ECS = require(RootFolder.ECS)

export type Destroyable = Types.HasEntity & {
	__destroyed: boolean,
	
	destroy: (self: Destroyable) -> (),
	--__internalDestroy: (self: Destroyable) -> (),
}

local methods = {}

function methods:__internalDestroy()
	if self.__destroyed then return end
	self.__destroyed = true

	local cleanupFn = ECS.World:get(self.entity, ECS.Components.CleanupFn)
	if cleanupFn then
		cleanupFn()
		
		ECS.World:remove(self.entity, ECS.Components.CleanupFn)
	end
end

function methods:destroy()
	if self.__destroyed then return end
	
	self:__internalDestroy()
	
	ECS.World:delete(self.entity)
end

return methods
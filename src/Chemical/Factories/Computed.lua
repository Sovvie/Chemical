local RootFolder = script.Parent.Parent

local ECS = require(RootFolder.ECS)
local Cache = require(RootFolder.Cache)

local Object = require(RootFolder.Classes.Object)

local Stateful = require(RootFolder.Mixins.Stateful)
local Destroyable = require(RootFolder.Mixins.Destroyable)
local Cleanable = require(RootFolder.Mixins.Cleanable)
local Computable = require(RootFolder.Mixins.Computable)


export type Computed<T> = Stateful.Stateful<T> & Computable.Computable<T> & Destroyable.Destroyable<T> & Cleanable.Cleanable<T> 

return function<T>(computeFn: () -> T, cleanupFn: (T) -> ()?): Computed<T>
	local obj = Object.new({
		__tostring = function(self)
			local rawValue = ECS.World:get(self.entity, ECS.Components.Value)
			return `Computed<{tostring(rawValue)}>`
		end,
	})
	ECS.World:add(obj.entity, ECS.Tags.IsStateful)
	ECS.World:add(obj.entity, ECS.Tags.IsComputed)


	ECS.World:set(obj.entity, ECS.Components.ComputeFn, computeFn)
	if cleanupFn then ECS.World:set(obj.entity, ECS.Components.CleanupFn, cleanupFn) end


	obj:use(
		Computable,
		Stateful,
		Destroyable,
		Cleanable
	)


	obj:compute()
	
	
	ECS.World:set(obj.entity, ECS.Components.Object, obj)
	

	return obj
end
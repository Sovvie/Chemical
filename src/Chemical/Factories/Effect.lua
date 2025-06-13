local RootFolder = script.Parent.Parent

local Classes = RootFolder.Classes
local Mixins = RootFolder.Mixins

local ECS = require(RootFolder.ECS)
local Object = require(Classes.Object)

local Effectable = require(Mixins.Effectable)
local Destroyable = require(Mixins.Destroyable)
local Cleanable = require(Mixins.Cleanable)

export type Effect = Effectable.Effectable & Destroyable.Destroyable & Cleanable.Cleanable
type CleanUp = () -> ()

--- Effect
-- Effects will fire after the batch of stateful object changes are propogated.
-- The optional cleanup function will fire first, and then the effect's function.
-- The effect function can optionally return a cleanup function.
-- Effects will be deleted when any one of its dependent objects are destroyed.
return function(effectFn: () -> ( CleanUp | nil )): Effect
	local obj = Object.new()


	ECS.World:add(obj.entity, ECS.Tags.IsEffect)
	ECS.World:set(obj.entity, ECS.Components.EffectFn, effectFn)


	obj:use(
		Cleanable,
		Destroyable,
		Effectable
	)


	obj:run()
	
	
	ECS.World:set(obj.entity, ECS.Components.Object, obj)
	

	return obj
end
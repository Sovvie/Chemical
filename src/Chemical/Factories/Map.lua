local RootFolder = script.Parent.Parent

local Classes = RootFolder.Classes
local Mixins = RootFolder.Mixins

local ECS = require(RootFolder.ECS)

local Object = require(Classes.Object)

local Stateful = require(Mixins.Stateful)
local StatefulTable = require(Mixins.StatefulTable)
local StatefulDictionary = require(Mixins.StatefulDictionary)

local Settable = require(Mixins.Settable)
local Numerical = require(Mixins.Numerical)
local Destroyable = require(Mixins.Destroyable)

export type Value<T> = Stateful.Stateful<T> & Settable.Settable<T> & StatefulDictionary.StatefulDictionary<T> & Destroyable.Destroyable

return function<T>(value: T): Value<T>
	local obj = Object.new({
		__tostring = function(self)
			return `Map<{self.entity}>`
		end,
	})
	ECS.World:add(obj.entity, ECS.Tags.IsStateful)
	ECS.World:add(obj.entity, ECS.Tags.IsStatefulDictionary)
	ECS.World:add(obj.entity, ECS.Tags.IsSettable)


	obj:use(
		Stateful,
		Settable,
		StatefulDictionary,
		Destroyable
	)


	ECS.World:set(obj.entity, ECS.Components.Value, value)
	ECS.World:set(obj.entity, ECS.Components.Object, obj)


	return obj
end

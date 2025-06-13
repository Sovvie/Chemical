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

type Value<T> = Stateful.Stateful<T> & Settable.Settable<T> & Destroyable.Destroyable

export type ValueFactory = (
	((value: number) -> Value<number> & Numerical.Numerical) &
	(<T>(value: T) -> Value<T>)
)

--- Value
-- Stateful value container which enables reactivity.
-- Depending on the type of the initial value, certain methods are exposed correlating to the value type.
-- @param value any -- The initial value to set.
-- @return The Value object.
return function<T>(value: T): Value<T>
	local obj = Object.new({
		__len = typeof(value) == "table" and function(self)
			return #ECS.World:get(self.entity, ECS.Components.Value)
		end or nil,
		
		__tostring = function(self)
			local rawValue = ECS.World:get(self.entity, ECS.Components.Value)
			return `Value<{tostring(rawValue)}>`
		end,
	})
	ECS.World:add(obj.entity, ECS.Tags.IsStateful)
	ECS.World:add(obj.entity, ECS.Tags.IsSettable)
	
	
	local mtMethods: { {} } = {
		Stateful,
		Settable,
		Destroyable,
	}
	
	
	if typeof(value) == "number" then
		table.insert(mtMethods, Numerical)
	end
	
	
	obj:use(table.unpack(mtMethods))
	
	
	ECS.World:set(obj.entity, ECS.Components.Value, value)
	ECS.World:set(obj.entity, ECS.Components.Object, obj)
	
	
	return obj
end

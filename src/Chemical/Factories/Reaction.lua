--!strict

local RootFolder = script.Parent.Parent


local LinkedList = require(RootFolder.Packages.LinkedList)


local Classes = RootFolder.Classes
local Mixins = RootFolder.Mixins
local Functions = RootFolder.Functions


local ECS = require(RootFolder.ECS)
local Is = require(Functions.Is)
local SetInScope = require(Functions.SetInScope)


local Object = require(Classes.Object)
local Stateful = require(Mixins.Stateful)
local Destroyable = require(Mixins.Destroyable)
local Serializable = require(Mixins.Serializable)

export type Reaction<T> = Stateful.Stateful<T> & Destroyable.Destroyable & Serializable.Serializable & T

--- Reaction
-- A Stateful container with helper methods for converting data into different formats.
local function createReaction<T>(name: string, key: string, container: T): Reaction<T>

	local obj = Object.new({
		__tostring = function(self)
			local isAlive = Is.Dead(self) and "Dead" or "Alive"
			return `Reaction<{name}/{key}> - {isAlive}`
		end,
	})
	ECS.World:add(obj.entity, ECS.Tags.IsStateful)
	
	SetInScope(container :: any, obj.entity)

	obj:use(
		Stateful,
		Destroyable,
		Serializable,
		(container :: any)
	)

	ECS.World:set(obj.entity, ECS.Components.Value, container)
	ECS.World:set(obj.entity, ECS.Components.Object, obj)

	return obj :: Reaction<T>
end

return createReaction
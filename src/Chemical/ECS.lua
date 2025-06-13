--!nonstrict
local Packages = script.Parent.Packages
local ECS = require(Packages.JECS)

export type Entity<T = nil> = ECS.Entity<T>

local Tags = {
	-- State Management Tags
	IsStatic = ECS.tag(),
	IsPrimitive = ECS.tag(),
	IsSettable = ECS.tag(),
	IsStateful = ECS.tag(),
	IsStatefulTable = ECS.tag(),
	IsStatefulDictionary = ECS.tag(),
	IsComputed = ECS.tag(),
	IsEffect = ECS.tag(),
	IsDirty = ECS.tag(),
	IsDeepComparable = ECS.tag(),

	-- Relationship Tags
	SubscribesTo = ECS.tag(),
	HasSubscriber = ECS.tag(),
	InScope = ECS.tag(),
	ChildOf = ECS.ChildOf,

	-- UI-specific Tags TODO
	IsHost = ECS.tag(),
	ManagedBy = ECS.tag(),
	UIParent = ECS.tag(),
}

local World = ECS.world()


local Components = {
	Name = ECS.Name,
	Object = World:component(),
	Value = World:component(),
	PrevValue = World:component(),
	Callback = World:component(),
	CallbackList = World:component(),
	OnChangeCallbacks = World:component(),
	OnKVChangeCallbacks = World:component(),
	Connection = World:component() :: ECS.Entity<RBXScriptConnection>,
	ConnectionList = World:component() :: ECS.Entity<{RBXScriptConnection}>,
	Instance = World:component(),
	ManagedItems = World:component(),
	LoopType = World:component(),


	ComputeFn = World:component(),
	EffectFn = World:component(),
	CleanupFn = World:component(),
}

World:set(Components.Connection, ECS.OnRemove, function(entity)
	local connection = World:get(entity, Components.Connection)
	if connection then
		connection:Disconnect()
	end
end)

World:set(Components.ConnectionList, ECS.OnRemove, function(entity)
	local connections = World:get(entity, Components.ConnectionList)
	if connections then
		for _, conn in ipairs(connections) do
			conn:Disconnect()
		end
	end
end)

World:set(Components.Instance, ECS.OnRemove, function(entity)
	if World:has(entity, Tags.IsHost) then
		for effectEntity in World:each(ECS.pair(Tags.InScope, entity)) do
			World:delete(effectEntity)
		end
		if World:has(entity, Components.ConnectionList) then
			World:remove(entity, Components.ConnectionList)
		end
	end
end)

World:set(Components.Value, ECS.OnChange, function(entity, id, data)
	if World:has(entity, Tags.IsSettable) then
		World:add(entity, Tags.IsDirty)
	end
end)

World:set(Components.Object, ECS.OnRemove, function(entity: ECS.Entity<any>, id: ECS.Id<any>)
	local object = World:get(entity, Components.Object)
	if object and object.__internalDestroy then
		object:__internalDestroy()
	end	
end)

World:add(Tags.SubscribesTo, ECS.pair(ECS.OnDeleteTarget, ECS.Delete))
World:add(Tags.HasSubscriber, ECS.pair(ECS.OnDeleteTarget, ECS.Delete))
World:add(Tags.InScope, ECS.pair(ECS.OnDeleteTarget, ECS.Delete))
World:add(Tags.ManagedBy, ECS.pair(ECS.OnDeleteTarget, ECS.Delete))
World:add(Tags.UIParent, ECS.pair(ECS.OnDeleteTarget, ECS.Delete))

local module = {
	Components = Components,
	Tags = Tags,
	JECS = ECS,
	World = World,
}

return module
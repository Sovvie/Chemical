local RootFolder = script.Parent.Parent

local ECS = require(RootFolder.ECS)
local Symbols = require(RootFolder.Symbols)

local Effect = require(RootFolder.Factories.Effect)

local Is = require(RootFolder.Functions.Is)
local Has = require(RootFolder.Functions.Has)
local GetInScope = require(RootFolder.Functions.GetInScope)

local JECS = ECS.JECS
local World = ECS.World
local Components = ECS.Components
local Tags = ECS.Tags

local RESERVED_KEYS = { "Children", "Parent" }

local INSTANCE_TO_ENTITY = setmetatable({}, { __mode = "k" })

local function applyProperty(instance, prop, value)
	instance[prop] = value
end

local function bindEvent(instance: Instance, instanceEntity: ECS.Entity, event, callback)
	local connection = instance[event]:Connect(callback)
	local connectionList = World:get(instanceEntity, Components.ConnectionList)
	table.insert(connectionList, connection)
	World:set(instanceEntity, Components.ConnectionList, connectionList)
end

local function bindChange(instance: Instance, instanceEntity: ECS.Entity, prop, action)
	local connection

	if Is.Settable(action) then
		connection = instance:GetPropertyChangedSignal(prop):Connect(function(...: any) action:set(instance[prop]) end)
	else
		connection = instance:GetPropertyChangedSignal(prop):Connect(action)
	end

	local connectionList = World:get(instanceEntity, Components.ConnectionList)
	table.insert(connectionList, connection)
	World:set(instanceEntity, Components.ConnectionList, connectionList)
end

local function bindReactive(instance: Instance, instanceEntity: ECS.Entity, prop, value): Effect.Effect
	local propType = typeof(instance[prop])
	local propIsString = propType == "string"

	local propEffect = Effect(function()
		local currentValue = value:get()

		if propIsString and typeof(currentValue) ~= "string" then
			instance[prop] = tostring(currentValue)
		else
			instance[prop] = currentValue
		end
	end)

	applyProperty(instance, prop, value:get())

	World:add(propEffect.entity, JECS.pair(Tags.InScope, instanceEntity))
end

local function applyVirtualNode(instance: Instance, instanceEntity: ECS.Entity, properties: {})
	for key, value in properties do
		if table.find(RESERVED_KEYS, key) then continue end

		if Is.Symbol(key) then
			if Has.Symbol("Event", key) then
				if Is.Stateful(value) then error("Chemical OnEvent Error: Chemical does not currently support Stateful values.") end
				if typeof(value) ~= "function" then error("Chemical OnEvent Error: can only be bound to a callback", 2) end


				bindEvent(instance, instanceEntity, key.Symbol, value)
			elseif Has.Symbol("Change", key) then
				if typeof(value) ~= "function" 
					and not Is.Settable(value) then error("Chemical OnChange Error: can only be bound to a callback or settable Stateful object.", 2) end


				bindChange(instance, instanceEntity, key.Symbol, value)
			elseif Has.Symbol("Children", key) then
				for _, child in value do
					child.Parent = instance
				end
			end
		elseif Is.Stateful(value) then
			bindReactive(instance, instanceEntity, key, value)
		elseif Is.Literal(value) then
			applyProperty(instance, key, value)
		end
	end
end

local function Compose(target: string | Instance)
	return function(properties: {})
		local instance: Instance
		local instanceEntity: ECS.Entity

		if typeof(target) == "string" then
			instance = Instance.new(target)
			instanceEntity = World:entity()

			World:add(instanceEntity, Tags.IsHost)
			World:set(instanceEntity, Components.Instance, instance)
			World:set(instanceEntity, Components.ConnectionList, {})

			World:set(instanceEntity, Components.Connection, instance.Destroying:Once(function()
				INSTANCE_TO_ENTITY[instance] = nil

				if World:contains(instanceEntity) then
					World:delete(instanceEntity)
				end
			end))
		else
			instance = target
			instanceEntity = INSTANCE_TO_ENTITY[instance]

			if not instanceEntity or not World:contains(instanceEntity) then
				instanceEntity = World:entity()
				INSTANCE_TO_ENTITY[instance] = instanceEntity

				World:add(instanceEntity, Tags.IsHost)
				World:set(instanceEntity, Components.Instance, instance)
				World:set(instanceEntity, Components.ConnectionList, {})

				World:set(instanceEntity, Components.Connection, instance.Destroying:Once(function()
					INSTANCE_TO_ENTITY[instance] = nil

					if World:contains(instanceEntity) then
						World:delete(instanceEntity)
					end
				end))
			end
		end

		applyVirtualNode(instance, instanceEntity, properties)

		if properties.Parent and not instance.Parent then
			instance.Parent = properties.Parent
		end

		return instance
	end
end

return Compose
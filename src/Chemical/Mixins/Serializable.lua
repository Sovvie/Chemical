--!strict
local RootFolder = script.Parent.Parent

local ECS = require(RootFolder.ECS)
local Cache = require(RootFolder.Cache)
local Types = require(RootFolder.Types)

local Is = require(RootFolder.Functions.Is)
local Peek = require(RootFolder.Functions.Peek)
local Array = require(RootFolder.Functions.Array)
local Blueprint = require(RootFolder.Functions.Blueprint)

export type Serializable = Types.HasEntity & {
	serialize: (self: Serializable) -> (any),
	snapshot: (self: Serializable) -> (any),
	blueprint: (self: Serializable) -> (any | { any }),
}

return {
	serialize = function(self: Serializable): any
		local value = ECS.World:get(self.entity, ECS.Components.Value)
		local serialized
		
		if Is.Stateful(value) then
			local theValue = Peek(value)
			serialized = Is.Primitive(theValue) and theValue
			
		elseif Is.Array(value) then
			serialized = Array.Transform(value, function(k, v)
				if Is.Stateful(v) then
					local theValue = Peek(v)
					return Is.Primitive(theValue) and theValue or nil
				elseif Is.Primitive(v) then
					return v
				end
				
				return nil
			end)
			
		elseif Is.Primitive(value) then
			serialized = value
			
		end
		
		return serialized, if not serialized then warn("There was nothing to serialize, or the value was unserializable.") else nil
	end,
	
	snapshot = function(self: Serializable): any
		local value = ECS.World:get(self.entity, ECS.Components.Value)
		
		if Is.Stateful(value) then
			return Peek(value)
		elseif Is.Array(value) then
			return Array.Transform(value, function(k, v)
				if Is.Stateful(v) then
					local theValue = Peek(v)
					return Peek(v)
				elseif Is.Primitive(v) then
					return v
				end

				return nil
			end)
		else
			return value
		end
	end,
	
	blueprint = function(self: Serializable): any | { any }
		local value = ECS.World:get(self.entity, ECS.Components.Value)
		return Blueprint:From(value)
	end,
}
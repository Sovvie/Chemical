local RootFolder = script.Parent.Parent

local ECS = require(RootFolder.ECS)

local module = {}

function module.Stateful(obj: any): boolean
	if typeof(obj) == "table" and obj.entity then
		return ECS.World:has(obj.entity, ECS.Tags.IsStateful)
	end
	
	return false
end

function module.Settable(obj: any): boolean
	if typeof(obj) == "table" and obj.entity then
		return ECS.World:has(obj.entity, ECS.Tags.IsSettable)
	end
	
	return false
end

function module.Primitive(obj: any): boolean
	local typeA = typeof(obj)
	return typeA ~= "table" and typeA ~= "userdata"
end

function module.Literal(obj: any): boolean
	local typeA = typeof(obj)
	return typeA ~= "table" and typeA ~= "userdata" and typeA ~= "thread" and typeA ~= "function" and typeA ~= "Instance"
end

function module.Symbol(obj: any, typeOf: string?): boolean
	local is = typeof(obj) == "table" and obj.Type and obj.Symbol
	return typeOf == nil and is or is and obj.Type == typeOf
end

function module.Array(obj: any): boolean
	return typeof(obj) == "table" and obj.entity == nil
end

function module.StatefulTable(obj: any): boolean
	if typeof(obj) == "table" and obj.entity then
		return ECS.World:has(obj.entity, ECS.Tags.IsStateful) and ECS.World:has(obj.entity, ECS.Tags.IsStatefulTable)
	end

	return false
end

function module.StatefulDictionary(obj: any): boolean
	if typeof(obj) == "table" and obj.entity then
		return ECS.World:has(obj.entity, ECS.Tags.IsStateful) and ECS.World:has(obj.entity, ECS.Tags.IsStatefulDictionary)
	end

	return false
end

function module.Blueprint(obj: any): boolean
	if typeof(obj) == "table" and obj.T and obj.V then
		return true
	end
	
	return false
end

function module.Dead(obj: any)
	return typeof(obj) == "table" and obj.__destroyed
end

function module.Destroyed(obj: Instance): boolean
	if obj.Parent == nil then
		local Success, Error = pcall(function()
			obj.Parent = UserSettings() :: any
		end)

		return Error ~= "Not allowed to add that under settings"
	end

	return false
end


return module

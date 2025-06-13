local RootFolder = script.Parent.Parent

local ECS = require(RootFolder.ECS)
local Cache = require(RootFolder.Cache)
local Types = require(RootFolder.Types)

local Value = require(RootFolder.Factories.Value)
local Table = require(RootFolder.Factories.Table)
local Map = require(RootFolder.Factories.Map)

local Is = require(RootFolder.Functions.Is)
local Peek = require(RootFolder.Functions.Peek)
local Array = require(RootFolder.Functions.Array)

type Blueprint = { T: ECS.Entity, V: any }

local module = {}


local function blueprintTreeFromValue(value: any): Blueprint
	if Is.Stateful(value) then
		if Is.StatefulTable(value) then
			return { T = ECS.Tags.IsStatefulTable, V = Peek(value) }
		elseif Is.StatefulDictionary(value) then
			return { T = ECS.Tags.IsStatefulDictionary, V = Peek(value) }
		else
			return { T = ECS.Tags.IsStateful, V = Peek(value) }
		end
	elseif typeof(value) == "table" then
		local childrenAsBlueprints = Array.ShallowTransform(value, function(k, v)
			return blueprintTreeFromValue(v)
		end)
		return { T = ECS.Tags.IsStatic, V = childrenAsBlueprints }
	else
		return { T = ECS.Tags.IsStatic, V = value }
	end
end


function module:From(value: any): Blueprint
	return blueprintTreeFromValue(value)
end


local buildFromBlueprintTree


local function buildFromABlueprint(blueprint: Blueprint)
	if blueprint.T == ECS.Tags.IsStateful then
		return Value(blueprint.V)
	elseif blueprint.T == ECS.Tags.IsStatefulTable then
		return Table(blueprint.V)
	elseif blueprint.T == ECS.Tags.IsStatefulDictionary then
		return Map(blueprint.V)
	elseif blueprint.T == ECS.Tags.IsStatic then
		if typeof(blueprint.V) == "table" then
			return buildFromBlueprintTree(blueprint.V)
		else
			return blueprint.V
		end
	end
	
	return nil
end


buildFromBlueprintTree = function(blueprintTable: {any})
	return Array.ShallowTransform(blueprintTable, function(key, value)
		return buildFromABlueprint(value)
	end)
end

function module:Read(rootBlueprint: Blueprint)
	return buildFromABlueprint(rootBlueprint)
end


return module
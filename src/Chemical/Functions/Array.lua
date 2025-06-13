local RootFolder = script.Parent.Parent

local ECS = require(RootFolder.ECS)
local Cache = require(RootFolder.Cache)
local Types = require(RootFolder.Types)

local Is = require(RootFolder.Functions.Is)




local module = {}

function module.Transform<K, V, R>(tbl: { [K]: V }, doFn: (k: K, v: V) -> R): { [K]: R }
	local newTbl = {}
	for key, value in tbl do
		if Is.Array(value) then
			newTbl[key] = module.Transform(value, doFn)
		else
			newTbl[key] = doFn(key, value)
		end
	end
	return newTbl
end

function module.ShallowTransform<K, V, R>(tbl: { [K]: V }, doFn: (k: K, v: V) -> R): { [K]: R }
	local newTbl = {}
	for key, value in tbl do
		newTbl[key] = doFn(key, value)
	end
	return newTbl
end


function module.Traverse(tbl: {}, doFn: (k: any, v: any) -> ())
	for key, value in tbl do
		if Is.Array(value) then
			module.Traverse(value, doFn)
		else
			doFn(key, value)
		end
	end
end

--[[
    Recursively walks a table, calling a visitor function for every
    value encountered. The visitor receives the path (an array of keys)
    and the value at that path.
    
    @param target The table to walk.
    @param visitor The function to call, with signature: (path: {any}, value: any) -> ()
--]]
function module.Walk(target: {any}, visitor: (path: {any}, value: any) -> ())
	local function _walk(currentValue: any, currentPath: {any})
		visitor(currentPath, currentValue)

		if Is.Array(currentValue) then
			for key, childValue in pairs(currentValue) do
				local childPath = table.clone(currentPath)
				table.insert(childPath, key)
				_walk(childValue, childPath)
			end
		end
	end

	_walk(target, {})
end



function module.FindOnPath<K, V>(tbl: {[K]: V}, path: { number | string }): V
	local current = tbl
	for _, key in path do
		current = current[key]
	end
	
	return current
end

return module

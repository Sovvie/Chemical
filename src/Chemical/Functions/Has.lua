local RootFolder = script.Parent.Parent

local ECS = require(RootFolder.ECS)

local module = {}

function module.Symbol(typeOf: string, obj: {}): boolean
	return obj.Type == typeOf
end


return module

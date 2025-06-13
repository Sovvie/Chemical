local RootFolder = script.Parent.Parent

local ECS = require(RootFolder.ECS)
local Types = require(RootFolder.Types)

return function(obj: Types.HasEntity): boolean
	return ECS.World:contains(obj.entity)
end

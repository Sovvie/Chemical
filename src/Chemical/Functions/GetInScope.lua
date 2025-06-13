local RootFolder = script.Parent.Parent

local ECS = require(RootFolder.ECS)

local function getInScope(entity: ECS.Entity)
	local scoped = {}
	for scopedEntity in ECS.World:each(ECS.JECS.pair(ECS.Tags.InScope, entity)) do
		table.insert(scoped, scopedEntity)
	end
	return scoped
end

return getInScope
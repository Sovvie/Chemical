local RootFolder = script.Parent.Parent

local ECS = require(RootFolder.ECS)
local Array = require(RootFolder.Functions.Array)
local Is = require(RootFolder.Functions.Is)

local function setInScope(scopable: {ECS.Entity} | ECS.Entity, entity: ECS.Entity)
	if Is.Stateful(scopable) then
		ECS.World:add(scopable.entity, ECS.JECS.pair(ECS.Tags.InScope, entity))
		
		return
	end
	
	Array.Traverse(scopable, function(k, v)
		if Is.Stateful(v) then
			ECS.World:add(v.entity, ECS.JECS.pair(ECS.Tags.InScope, entity))
		end
	end)
end

return setInScope
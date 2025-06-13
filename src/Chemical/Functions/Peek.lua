local RootFolder = script.Parent.Parent

local ECS = require(RootFolder.ECS)

local Is = require(RootFolder.Functions.Is)

--- Peek
-- View a stateful's value without triggering and scoped dependencies/subscriptions.
return function(obj: any): any?
	if Is.Stateful(obj) then
		return ECS.World:get(obj.entity, ECS.Components.Value)
	end
	
	return nil
end

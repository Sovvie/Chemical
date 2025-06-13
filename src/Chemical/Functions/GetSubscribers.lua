local RootFolder = script.Parent.Parent

local ECS = require(RootFolder.ECS)

	

local function getSubscribers(entity: ECS.Entity)
	local subscribers = {}

	local subscriberQuery = ECS.World:query(ECS.Components.Object)
		:with(ECS.JECS.pair(ECS.Tags.SubscribesTo, entity))

	for subscriberEntity, _ in subscriberQuery:iter() do
		table.insert(subscribers, subscriberEntity)
	end

	return subscribers
end

return getSubscribers
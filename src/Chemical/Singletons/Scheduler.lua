--!native
--!optimize 2

local RunService = game:GetService("RunService")

local RootFolder = script.Parent.Parent

local ECS = require(RootFolder.ECS)

local Components = ECS.Components
local Tags = ECS.Tags
local JECS = ECS.JECS
local World = ECS.World

local MAX_COMPUTATION_DEPTH = 100

local dirtySourceQuery = World:query(Components.Object)
	:with(Tags.IsStateful, Tags.IsDirty)
	:without(Tags.IsEffect, Tags.IsComputed)
	:cached()

local dirtyComputedsQuery = World:query(Components.Object)
	:with(Tags.IsComputed, Tags.IsDirty)
	:cached()

local dirtyEffectsQuery = World:query(Components.Object)
	:with(Tags.IsEffect, Tags.IsDirty)
	:cached()


local GetSubscribers = require(RootFolder.Functions.GetSubscribers)


local Scheduler = {}

function Scheduler:Update()
	-- PROPAGATE DIRTINESS
	for sourceEntity, _ in dirtySourceQuery:iter() do
		local subscribers = GetSubscribers(sourceEntity)

		for _, subscriberEntity in ipairs(subscribers) do
			if not World:has(subscriberEntity, Tags.IsDirty) then
				World:add(subscriberEntity, Tags.IsDirty)
			end
		end

		World:remove(sourceEntity, Tags.IsDirty)
	end

	-- RE-RUN COMPUTED VALUES
	for i = 1, MAX_COMPUTATION_DEPTH do
		local computedsToProcess = {}
		
		for entity, computable in dirtyComputedsQuery:iter() do
			table.insert(computedsToProcess, computable)
		end

		if #computedsToProcess == 0 then
			break
		end

		for _, computable in ipairs(computedsToProcess) do

			computable:compute()
			World:remove(computable.entity, Tags.IsDirty)
			
			for _, subscriber in ipairs(GetSubscribers(computable.entity)) do
				World:add(subscriber, Tags.IsDirty)
			end
		end

		if i == MAX_COMPUTATION_DEPTH then
			warn("Chemical: Max computation depth exceeded. Check for a circular dependency in your Computed values.")
		end
	end

	-- RUN EFFECTS & OBSERVERS
	for _, runnable in dirtyEffectsQuery:iter() do
		runnable:run()
		World:remove(runnable.entity, Tags.IsDirty)
	end
end

if RunService:IsServer() then
	RunService.Heartbeat:Connect(function()
		Scheduler:Update()
	end)
else
	RunService.RenderStepped:Connect(function()
		Scheduler:Update()
	end)
end


return Scheduler
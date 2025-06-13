--[[
	@module Reactor
	
	This module facilitates the creation and replication of stateful objects, called "Reactions,"
	from the server to clients. It is designed to be used in an ECS (Entity-Component System)
	environment.
	
	- A "Reactor" is a factory for creating "Reactions" of a specific type.
	- A "Reaction" is a state object identified by a name and a unique key.
	- State changes within a Reaction are automatically replicated to the appropriate clients.
	- It uses a tokenization system to minimize network bandwidth for property names and paths.
	
	Yes, the documentation was generated.
]]


local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local RootFolder = script.Parent.Parent


local Packet = require(RootFolder.Packages.Packet)
local Signal = require(RootFolder.Packages.Signals)
local Promise = require(RootFolder.Packages.Promise)
local Queue = require(RootFolder.Packages.Queue)


local ECS = require(RootFolder.ECS)
local Cache = require(RootFolder.Cache)
local Symbols = require(RootFolder.Symbols)
local Effect = require(RootFolder.Factories.Effect)
local Reaction = require(RootFolder.Factories.Reaction)
local Array = require(RootFolder.Functions.Array)
local Blueprint = require(RootFolder.Functions.Blueprint)
local Is = require(RootFolder.Functions.Is)


type Player = { UserId: number }
type Symbol = Symbols.Symbol
type Reaction<T> = Reaction.Reaction<T> & { To: { Player } | Symbol, Name: string, Key: string }


local network = {
	Create = Packet("C__Create", Packet.String, Packet.String, { Packet.NumberU8 }, Packet.Any, Packet.Any),
	Update = Packet("C__Update", { Packet.NumberU8 }, { Packet.NumberU8 }, Packet.Any),
	UpdateChanges = Packet("C__UpdateChange", { Packet.NumberU8 }, { Packet.NumberU8 }, Packet.Any), -- TODO
	Destroy = Packet("C__Destroy", { Packet.NumberU8 }),
}

local Tokens = Cache.Tokens.new()
local Reactions: { [string]: { [string]: Reaction<any> } } = {}
local ReactionQueues: { [string]: { [string]: Queue.Queue<{ { number } | any }> } } = {}
local OnReactionCreated = Signal.new()



--- Recursively walks a table structure and creates a map of string keys to numerical tokens.
-- This is used to prepare a state object for replication, ensuring the client can reconstruct it.
local function createPathTokenMap(
	snapshotTable: { [any]: any },
	originalTable: { [any]: any }
): { [string]: number }
	local result = {}

	for key, snapshotValue in pairs(snapshotTable) do
		local originalValue = originalTable[key]


		if typeof(key) ~= "string" then
			continue
		end


		result[key] = Tokens:ToToken(key)


		if Is.Array(snapshotValue) and Is.Array(originalValue) then
			for k, token in createPathTokenMap(snapshotValue, originalValue) do
				result[k] = token
			end
		end
	end

	return result
end

--- Sends a network packet to a specified target (all players or a list of players).
local AllPlayers = Symbols.All("Players")
local function sendToTarget(target: { Player } | Symbol, packet: any, ...: any)
	if target == AllPlayers then
		packet:Fire(...)
	else
		for _, player in target :: { Player } do
			packet:FireClient(player, ...)
		end
	end
end

--- Handles the server-side logic for replicating a Reaction to clients.
local function replicate(reaction: Reaction<any>)
	local name = reaction.Name
	local key = reaction.Key
	local target = reaction.To


	local nameToken = Tokens:ToToken(name)
	local keyToken = Tokens:ToToken(key)
	local reactionIdTokens = { nameToken, keyToken }

	local blueprint = reaction:blueprint()
	local pathTokenMap = createPathTokenMap(reaction:snapshot(), reaction:get())


	sendToTarget(target, network.Create, name, key, reactionIdTokens, pathTokenMap, blueprint)


	Array.Walk(reaction:get(), function(path: { string }, value: any)
		if Is.Stateful(value) then
			local pathTokens = Tokens:ToTokenPath(path)

			local eff = Effect(function()
				sendToTarget(target, network.Update, reactionIdTokens, pathTokens, value:get())
			end)


			ECS.World:add(eff.entity, ECS.JECS.pair(ECS.Tags.InScope, reaction.entity))
		end
	end)

	-- Patch the reaction's cleanup to notify clients of its destruction.
	ECS.World:set(reaction.entity, ECS.Components.CleanupFn, function()
		if Reactions[name] and Reactions[name][key] then
			Reactions[name][key] = nil
		end
		sendToTarget(target, network.Destroy, reactionIdTokens)
	end)
end


if RunService:IsClient() then
	--- Reconstructs a Reaction on the client based on data from the server.
	local function reconstruct(name: string, key: string, reactionIdTokens: { number }, pathTokenMap: { [string]: number }, blueprint: { string: {T: number, V: any} }): ()
		if Reactions[name] and Reactions[name][key] then
			return
		end

		-- Map the incoming tokens so we can translate them back to strings later.
		Tokens:Map({ [name] = reactionIdTokens[1], [key] = reactionIdTokens[2] })
		Tokens:Map(pathTokenMap)

		-- Create the local version of the Reaction
		local reaction = Reaction(name, key, Blueprint:Read(blueprint :: any))
		reaction.Name = name
		reaction.Key = key

		if not Reactions[name] then
			Reactions[name] = {}
		end
		Reactions[name][key] = reaction

		-- Process any queued updates that arrived before this creation packet.
		if ReactionQueues[name] and ReactionQueues[name][key] then
			local queue = ReactionQueues[name][key]
			while not queue:isEmpty() do
				local args = queue:dequeue()
				local pathTokens, value = table.unpack(args)
				local path = Tokens:FromPath(pathTokens)
				local statefulValue = Array.FindOnPath(reaction:get(), path)
				if statefulValue and statefulValue.set then
					statefulValue:set(value)
				end
			end
			ReactionQueues[name][key] = nil -- Clear the queue
		end

		OnReactionCreated:Fire(name, key, reaction)
	end

	--- Applies a state update from the server to a local Reaction.
	local function update(reactionIdTokens: { number }, pathTokens: { number }, value: any)
		local name = Tokens:From(reactionIdTokens[1])
		local key = Tokens:From(reactionIdTokens[2])
		local path = Tokens:FromPath(pathTokens)

		if not name or not key then return end

		local reaction = Reactions[name] and Reactions[name][key]

		-- If the reaction doesn't exist yet, queue the update.
		if not reaction then
			if not ReactionQueues[name] then ReactionQueues[name] = {} end
			if not ReactionQueues[name][key] then ReactionQueues[name][key] = Queue.new() end

			ReactionQueues[name][key]:enqueue({ pathTokens, value })
			return
		end

		if reaction.__destroyed then return end

		-- Apply the update
		local container = reaction:get()
		local statefulValue = Array.FindOnPath(container, path)
		if statefulValue and statefulValue.set then
			statefulValue:set(value)
		end
	end

	--- Destroys a local Reaction when notified by the server.
	local function destroy(reactionIdTokens: { number })
		local name = Tokens:From(reactionIdTokens[1])
		local key = Tokens:From(reactionIdTokens[2])

		if not name or not key then return end

		local reaction = Reactions[name] and Reactions[name][key]

		if not reaction or not reaction.entity then return end

		reaction:destroy()
		Reactions[name][key] = nil
	end

	-- Connect client network events to their handler functions
	network.Create.OnClientEvent:Connect(reconstruct)
	network.Update.OnClientEvent:Connect(update)
	network.Destroy.OnClientEvent:Connect(destroy)
else
	Players.PlayerAdded:Connect(function(player: Player)
		for _, keyedReactions in Reactions do
			for _, reaction in keyedReactions do
				if reaction.To == Symbols.All("Players") or table.find(reaction.To, player) then
					replicate(reaction)
				end
			end
		end
	end)
end

--// Public API
local api = {}

--- Awaits the creation of a specific Reaction on the client.
-- @param name The name of the Reactor that creates the Reaction.
-- @param key The unique key of the Reaction.
-- @return A promise that resolves with the Reaction once it's created.
function api.await<T>(name: string, key: string): Reaction<T>
	if Reactions[name] and Reactions[name][key] then
		return Reactions[name][key]
	end

	return Promise.fromEvent(OnReactionCreated, function(n: string, k: string, _)
		return name == n and key == k
	end):andThen(function(...)
		return select(3, ...) -- Return the reaction object
	end):expect()
end

--- Listens for the creation of any Reaction from a specific Reactor.
-- @param name The name of the Reactor.
-- @param callback A function to call with the key and Reaction object.
-- @return A connection object with a :Disconnect() method.
function api.onCreate(name: string, callback: (key: string, reaction: Reaction<any>) -> ())
	return OnReactionCreated:Connect(function(n: string, k: string, reaction: Reaction<any>)
		if n == name then
			task.spawn(callback, k, reaction)
		end
	end)
end

--- Creates a "Reactor" factory.
-- @param config A configuration table with a 'Name' and optional 'Subjects' (players).
-- @param constructor A function that returns the initial state for a new Reaction.
-- @return A Reactor object with `create` and `await` methods.
return function<T, U...>(
	config: { Name: string, Subjects: { Player } | Symbol? },
	constructor: (key: string, U...) -> T
)
	local name = config.Name
	assert(name, "Reactor config must include a 'Name'.")

	local to = config.Subjects or Symbols.All("Players")
	local reactor = {}

	--- Creates and replicates a new Reaction. [SERVER-ONLY]
	-- @param self The reactor object.
	-- @param key A unique key for this Reaction.
	-- @param ... Additional arguments to be passed to the constructor.
	-- @return The created Reaction instance.
	function reactor:create(key: string, ...: U...): Reaction<T>
		assert(not RunService:IsClient(), "Reactions can only be created on the server.")
		if Reactions[name] and Reactions[name][key] then
			warn(string.format("Reactor '%s' is overwriting an existing reaction with key '%s'", name, key))
		end

		local reaction = Reaction(name, key, constructor(key, ...))
		reaction.To = to
		reaction.Name = name
		reaction.Key = key

		if not Reactions[name] then
			Reactions[name] = {}
		end
		Reactions[name][key] = reaction

		-- The new, encapsulated replicate function handles all server-side logic.
		replicate(reaction)

		return reaction
	end

	--- Awaits a specific Reaction from this Reactor. [CLIENT-ONLY]
	function reactor:await(key: string): Reaction<T>
		return api.await(name, key)
	end

	--- Listens for new Reactions created by this Reactor. [CLIENT-ONLY]
	function reactor:onCreate(callback: (key: string, reaction: Reaction<T>) -> ())
		return api.onCreate(name, callback)
	end

	return reactor
end
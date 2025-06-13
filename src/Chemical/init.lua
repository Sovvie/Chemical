--!strict

--version 0.2.5 == Sovereignty

--TODO:
	-- Reactors and Reactions: Tables and Maps change networking, rather than full value networking on change.
	-- Export Types
	-- Improve file organization
	-- Templating
	-- Entity recycling - if possible

local ECS = require(script.ECS)
local Overrides = require(script.Types.Overrides)

local Value = require(script.Factories.Value)
local Table = require(script.Factories.Table)
local Map = require(script.Factories.Map)
local Computed = require(script.Factories.Computed)
local Observer = require(script.Factories.Observer)
local Watch = require(script.Factories.Watch)
local Effect = require(script.Factories.Effect)
local Reaction = require(script.Factories.Reaction)


local Compose = require(script.Functions.Compose)


local Is = require(script.Functions.Is)
local Peek = require(script.Functions.Peek)
local Array = require(script.Functions.Array)
local Alive = require(script.Functions.Alive)
local Destroy = require(script.Functions:FindFirstChild("Destroy"))
local Blueprint = require(script.Functions.Blueprint)

local Symbols = require(script.Symbols)

local Scheduler = require(script.Singletons.Scheduler)
local Reactor = require(script.Singletons.Reactor)


return {
	Value = (Value :: any) :: Value.ValueFactory,
	Table = Table,
	Map = Map,
	Computed = Computed,
	Observer = Observer,
	Watch = Watch,
	Effect = Effect,
	Reaction = Reaction,


	Compose = (Compose :: any) :: Overrides.ComposeFunction,
	Reactor = Reactor,

	Is = Is,
	Peek = Peek,
	Array = Array,
	Alive = Alive,
	Destroy = Destroy,
	Blueprint = Blueprint,
	
	
	OnEvent = Symbols.OnEvent,
	OnChange = Symbols.OnChange,
	Children = Symbols.Children
}
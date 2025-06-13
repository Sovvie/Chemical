--!strict

local RootFolder = script.Parent.Parent


local LinkedList = require(RootFolder.Packages.LinkedList)


local Classes = RootFolder.Classes
local Mixins = RootFolder.Mixins
local Functions = RootFolder.Functions


local ECS = require(RootFolder.ECS)
local Is = require(Functions.Is)
 
 
local Object = require(Classes.Object)
local Stateful = require(Mixins.Stateful)
local Observable = require(Mixins.Observable)
local Destroyable = require(Mixins.Destroyable)


export type Observer<T> = Observable.Observable<T> & Destroyable.Destroyable
export type ObserverTable<T> = Observable.ObservableTable<T> & Destroyable.Destroyable

export type ObserverFactory = (<T>(sourceObject: Stateful.Stateful<{T}>) -> ObserverTable<T>)
& (<T>(sourceObject: Stateful.Stateful<T>) -> Observer<T>)


--- Observer
-- Creates an observer that reacts to changes in a stateful source.
-- If the subject's value is a table, upon first creation of Observer, onKVChange callbacks will be supported. 
-- @param sourceObject The stateful object to observe.
-- @return A new observer object.
local function createObserver<T>(sourceObject: Stateful.Stateful<T>)
	if not Is.Stateful(sourceObject) then
		error("The first argument of an Observer must be a stateful object.", 2)
	end

	local obj = Object.new()
	ECS.World:add(obj.entity, ECS.Tags.IsEffect)


	ECS.World:set(obj.entity, ECS.Components.OnChangeCallbacks, LinkedList.new())


	if typeof(sourceObject:get()) == "table" then
		ECS.World:add(sourceObject.entity, ECS.Tags.IsDeepComparable)
		ECS.World:set(obj.entity, ECS.Components.OnKVChangeCallbacks, LinkedList.new())
	end


	ECS.World:add(obj.entity, ECS.JECS.pair(ECS.Tags.SubscribesTo, sourceObject.entity))
	ECS.World:add(sourceObject.entity, ECS.JECS.pair(ECS.Tags.HasSubscriber, obj.entity))


	obj:use(
		Destroyable,
		Observable
	)


	ECS.World:set(obj.entity, ECS.Components.Object, obj)


	return obj
end

return (createObserver :: any) :: ObserverFactory
--!strict

local RootFolder = script.Parent.Parent

local LinkedList = require(RootFolder.Packages.LinkedList)

local Types = require(RootFolder.Types)
local ECS = require(RootFolder.ECS)
local DeepCompare = require(RootFolder.Functions.Compare)


export type Observable<T = any> = Types.HasEntity & {
	__destroyed: boolean,
	onChange: (self: Observable<T>, callback: (new: T, old: T) -> ()) -> { disconnect: () -> () },
	run: (self: Observable<T>) -> (),
	destroy: (self: Observable<T>) -> (),
}

export type ObservableTable<T = {}> = Observable<T> & {
	onKVChange: (self: ObservableTable<T>, callback: (path: {string|number}, new: any, old: any) -> ()) -> { disconnect: () -> () },
}

return {
	onChange = function(self: Observable, callback: (any, any) -> ())
		local callbackList = ECS.World:get(self.entity, ECS.Components.OnChangeCallbacks)
		callbackList:InsertBack(callback)

		return {
			disconnect = function()
				callbackList:Remove(callback)
			end,
		}
	end,

	onKVChange = function(self: Observable, callback: (path: {any}, any, any) -> ())
		local kvCallbackList = ECS.World:get(self.entity, ECS.Components.OnKVChangeCallbacks)
		kvCallbackList:InsertBack(callback)

		return {
			disconnect = function()
				kvCallbackList:Remove(callback)
			end,
		}
	end,

	run = function(self: Observable)
		local sourceEntity = ECS.World:target(self.entity, ECS.Tags.SubscribesTo)
		if not sourceEntity then return end

		local newValue = ECS.World:get(sourceEntity, ECS.Components.Value)
		local oldValue = ECS.World:get(sourceEntity, ECS.Components.PrevValue)


		local callbacksList = ECS.World:get(self.entity, ECS.Components.OnChangeCallbacks)
		if callbacksList then
			for link, callback in callbacksList:IterateForward() do
				local s, err = pcall(callback, newValue, oldValue)
				if not s then warn("Chemical Observer Error: onChange: ", err) end
			end
		end


		if ECS.World:has(sourceEntity, ECS.Tags.IsDeepComparable) then
			local kvCallbackList = ECS.World:get(self.entity, ECS.Components.OnKVChangeCallbacks)
			if kvCallbackList then
				local changes = DeepCompare(oldValue, newValue)
				for _, change in ipairs(changes) do
					for link, callback in kvCallbackList:IterateForward() do
						local s, err = pcall(callback, change.Path, change.NewValue, change.OldValue)
						if not s then warn("Chemical Observer Error: onKVChange: ", err) end
					end
				end
			end
		end
	end,


	__internalDestroy = function(self: Observable & Types.MaybeCleanable)
		if self.__destroyed then return end
		self.__destroyed = true


		local callbacksList = ECS.World:get(self.entity, ECS.Components.OnChangeCallbacks)
		if callbacksList then callbacksList:Destroy() end

		local kvCallbackList = ECS.World:get(self.entity, ECS.Components.OnKVChangeCallbacks)
		if kvCallbackList then kvCallbackList:Destroy() end


		if self.clean then self:clean() end
		
		
		setmetatable(self, nil)
	end,

	destroy = function(self: Observable & Types.MaybeCleanable & Types.MaybeDestroyable)
		if self.__destroyed then return end

		self:__internalDestroy()

		ECS.World:delete(self.entity)
	end,
}
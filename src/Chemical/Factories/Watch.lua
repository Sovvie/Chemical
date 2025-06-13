local RootFolder = script.Parent.Parent

local Types = require(RootFolder.Types)

local Observer = require(RootFolder.Factories.Observer)

local Stateful = require(RootFolder.Mixins.Stateful)
local Computable = require(RootFolder.Mixins.Computable)


export type WatchHandle = {
	destroy: (self: WatchHandle) -> ()
}


type Watchable<T> = Stateful.Stateful<T> | Computable.Computable<T>

--- Creates a watcher that runs a callback function whenever a reactive source changes.
-- @param source The Value or Computed object to watch.
-- @param watchCallback A function that will be called with (newValue, oldValue).
-- @returns A handle with a :destroy() method to stop watching.
return function<T>(source: Watchable<T>, watchCallback: (new: T, old: T) -> ()): WatchHandle
	if not source or not source.entity then
		error("Chemical.Watch requires a valid Value or Computed object as its first argument.", 2)
	end

	if typeof(watchCallback) ~= "function" then
		error("Chemical.Watch requires a function as its second argument.", 2)
	end

	local obs = Observer(source)

	obs:onChange(function(newValue, oldValue)
		local success, err = pcall(watchCallback, newValue, oldValue)
		if not success then
			warn("Chemical Watch Error: ", err)
		end
	end)

	local handle: WatchHandle = {
		destroy = function()
			obs:destroy()
		end,
	}

	return handle
end
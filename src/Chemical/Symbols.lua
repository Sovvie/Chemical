local RootFolder = script.Parent

local GuiTypes = require(RootFolder.Types.Gui)
local GetSymbol = require(RootFolder.Functions.GetSymbol)

export type Symbol<S = string, T = string> = GetSymbol.Symbol<S, T>

local module = {}

module.OnEvent = function(eventName: GuiTypes.EventNames)
	return GetSymbol(eventName, "Event")
end

module.OnChange = function(eventName: GuiTypes.PropertyNames)
	return GetSymbol(eventName, "Change")
end

module.Children = GetSymbol("All", "Children")

module.All = function<S>(subjects: S)
	return GetSymbol(subjects, "All") :: Symbol<S, "All">
end

--OnEvent symbols are handled by the OnEvent function.

return module

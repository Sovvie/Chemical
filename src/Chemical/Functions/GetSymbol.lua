local RootFolder = script.Parent.Parent

local symbolMap = {}

export type Symbol<S, T> = { Symbol: S, Type: T }

return function<S, T>(symbolName: S, symbolType: T): Symbol<S, T>
	if symbolMap[symbolName] then return symbolMap[symbolName] end

	local symbol = { Symbol = symbolName, Type = symbolType }
	symbolMap[symbolName] = symbol

	return symbol
end

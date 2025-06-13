export type Change = {
	Path: {string | number},
	OldValue: any,
	NewValue: any,
}

local DeepCompare = {}

local function compare(oldTable, newTable, path, changes)
	path = path or {}
	changes = changes or {}

	for key, newValue in pairs(newTable) do
		local oldValue = oldTable and oldTable[key]
		local currentPath = table.clone(path)
		table.insert(currentPath, key)

		if oldValue ~= newValue then
			if typeof(newValue) == "table" and typeof(oldValue) == "table" then
				compare(oldValue, newValue, currentPath, changes)
			else
				table.insert(changes, {
					Path = currentPath,
					OldValue = oldValue,
					NewValue = newValue,
				})
			end
		end
	end

	if oldTable then
		for key, oldValue in pairs(oldTable) do
			if newTable[key] == nil then
				local currentPath = table.clone(path)
				table.insert(currentPath, key)

				table.insert(changes, {
					Path = currentPath,
					OldValue = oldValue,
					NewValue = nil,
				})
			end
		end
	end

	return changes
end

--- Compares two tables deeply and returns an array of changes.
-- Each change object contains a `Path`, `OldValue`, and `NewValue`.
return function(oldTable: {}, newTable: {}): {Change}
	if typeof(oldTable) ~= "table" or typeof(newTable) ~= "table" then
		return {}
	end

	return compare(oldTable, newTable)
end
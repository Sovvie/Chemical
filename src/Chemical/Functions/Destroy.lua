export type Destroyable = Computed | Value | Observer | { destroy: (self: {}) -> () } | Instance | RBXScriptConnection | { Destroyable } | () -> () | thread

local function Destroy(subject: Destroyable )
	if typeof(subject) == "table" then
		if subject.destroy then
			subject:destroy()
			
			return 
		end
		
		if subject.Destroy then
			subject:Destroy()
			
			return
		end

		if getmetatable(subject) then
			setmetatable(subject, nil)
			table.clear(subject)

			return
		end

		for _, value in subject do
			Destroy(value)
		end
	elseif typeof(subject) == "Instance" then
		subject:Destroy()
	elseif typeof(subject) == "RBXScriptConnection" then
		subject:Disconnect()
	elseif typeof(subject) == "function" then
		subject()
	elseif typeof(subject) == "thread" then
		task.cancel(subject)
	end
end

return Destroy

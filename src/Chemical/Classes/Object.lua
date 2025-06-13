local RootFolder = script.Parent.Parent

local Types = require(RootFolder.Types)
local ECS = require(RootFolder.ECS)

local module = {}

type Object = Types.HasEntity & {
	use: (self: Object, ...{}) -> (),
}

function module.new(metamethods: {}?): Object
	local inherits = {}
	metamethods = metamethods or {}
	
	metamethods.__index = function(self, index)
		local has = rawget(self, index)
		if has then return has
		else if inherits[index] then return inherits[index] end
		end
	end
	
	local object = setmetatable({
		entity = ECS.World:entity()
	}, metamethods)
	
	object.use = function(self, ...: {})
		local classes = { ... }
		for _, class in classes do
			for key, value in class do
				inherits[key] = value
			end
		end
		
		object.use = nil
	end
	
	return object
end

return module

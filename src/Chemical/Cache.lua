local module = {}
module.Tokens = {}
module.Stack = {}
module.Queues = {}

do
	local tokenCount = 0
	local stringsToTokens = {}
	local tokensToSrings = {}

	local tokenMap = {}

	function module:Tokenize(key: string): number
		if stringsToTokens[key] then return stringsToTokens[key] end

		tokenCount += 1

		stringsToTokens[key] = tokenCount
		tokensToSrings[tokenCount] = key

		return tokenCount
	end

	function module:FromToken(token: number): string
		return tokensToSrings[token]
	end


	function module:MapAToken(key: string, token: number)
		tokenMap[token] = key
	end

	function module:FromAMap(token: number): string
		return tokenMap[token]
	end

	function module:TokenClear(key: string | number)
		if typeof(key) == "string" then
			local token = stringsToTokens[key]
			stringsToTokens[key] = nil
			tokensToSrings[token] = nil
		elseif typeof(key) == "number" then
			local str = tokensToSrings[key]
			stringsToTokens[str] = nil
			tokensToSrings[key] = nil
		end
	end
end

function module.Tokens.new()
	local tokenCount = 0
	local stringsToTokens = {}
	local tokensToSrings = {}
	
	return {
		ToToken = function(self: {}, key: string): number
			if stringsToTokens[key] then return stringsToTokens[key] end
			
			tokenCount += 1

			stringsToTokens[key] = tokenCount
			tokensToSrings[tokenCount] = key
			return tokenCount
		end,
		
		ToTokenPath = function(self: {}, keys: {string}): { number }
			local tokens = {}
			
			for _, key in keys do
				table.insert(tokens, self:ToToken(key))
			end
			
			return tokens
		end,
		
		Is = function(self: {}, key: string): boolean
			return stringsToTokens[key] ~= nil
		end,
		
		From = function(self: {}, token: number): string
			return tokensToSrings[token]
		end,
		
		FromPath = function(self: {}, tokens: { number }): { string }
			local strings = {}
			for _, token in tokens do
				table.insert(strings, tokensToSrings[token])
			end
			return strings
		end,
		
		Map = function(self: {}, stringsToTokens: { [string]: number })
			for key, value in stringsToTokens do
				if typeof(value) == "table" then
					self:Map(value)
					continue
				end
				stringsToTokens[key] = value
				tokensToSrings[value] = key
			end
		end,
	}
end


local stack = {}
function module.Stack:Push(entry: any): number
	table.insert(stack, entry)
	return #stack
end

function module.Stack:Top(): any
	return stack[#stack]
end

function module.Stack:Pop(index: number?)
	stack[index or #stack] = nil
end




return module

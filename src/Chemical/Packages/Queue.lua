--!strict

--From Roblox docs

local Queue = {}
Queue.__index = Queue

export type Queue<T> = typeof(setmetatable(
	{} :: {
		_first: number,
		_last: number,
		_queue: { T },
	},
	Queue
	))

function Queue.new<T>(): Queue<T>
	local self = setmetatable({
		_first = 0,
		_last = -1,
		_queue = {},
	}, Queue)

	return self
end

-- Check if the queue is empty
function Queue.isEmpty<T>(self: Queue<T>)
	return self._first > self._last
end

-- Add a value to the queue
function Queue.enqueue<T>(self: Queue<T>, value: T)
	local last = self._last + 1
	self._last = last
	self._queue[last] = value
end

-- Remove a value from the queue
function Queue.dequeue<T>(self: Queue<T>): T?
	if self:isEmpty() then
		return nil
	end

	local first = self._first
	local value = self._queue[first]
	self._queue[first] = nil
	self._first = first + 1

	return value
end

return Queue
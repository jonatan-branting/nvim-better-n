local Repeatable = {}

function Repeatable:new(opts)
	local instance = {
		register = opts.register or error("opts.register is required" .. vim.inspect(opts)),
		key = opts.key or error("opts.trigger is required" .. vim.inspect(opts)),
		next_action = opts.next or error("opts.next is required" .. vim.inspect(opts)),
		previous_action = opts.previous or error("opts.previous is required" .. vim.inspect(opts)),
	}

	setmetatable(instance, self)
	self.__index = self

	instance.passthrough = function()
		return instance:_passthrough()
	end
	instance.next = function()
		return instance:_next()
	end
	instance.previous = function()
		return instance:_previous()
	end

	return instance
end

function Repeatable:_next()
	self.register.last_key = self.key

	if type(self.next_action) == "function" then
		return vim.schedule(self.next_action)
	else
		return vim.v.count1 .. self.next_action
	end
end

function Repeatable:_previous()
	self.register.last_key = self.key

	if type(self.previous_action) == "function" then
		return vim.schedule(self.previous_action)
	else
		return vim.v.count1 .. self.previous_action
	end
end

function Repeatable:_passthrough()
	self.register.last_key = self.key

	return self.key
end

return Repeatable

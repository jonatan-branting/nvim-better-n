local Repeatable = require("better-n.repeatable")

local augroup = vim.api.nvim_create_augroup("BetterN", {})

local Register = {}

function Register:new()
	local instance = {
		last_key = nil,
		repeatables = {},
	}

	setmetatable(instance, self)
	self.__index = self

	-- https://stackoverflow.com/questions/27426704/lua-5-1-workaround-for-gc-metamethod-for-tables
	-- TODO: has to be cleaned up if this is unloaded
	vim.api.nvim_create_autocmd("CmdlineLeave", {
		group = augroup,
		callback = function()
			local abort = vim.v.event.abort
			local cmdline_char = vim.fn.expand("<afile>")

			if not abort and instance.repeatables[cmdline_char] ~= nil then
				instance.last_key = cmdline_char
			end
		end,
	})

	return instance
end

function Register:create(opts)
	local key = opts.key or self:_generate_key()

	self.repeatables[key] = Repeatable:new({
		register = self,
		key = key,
		next = opts.next,
		previous = opts.previous,
	})

	return self.repeatables[key]
end

function Register:register(...)
	self:create(...)

	return self
end

function Register:next()
	if self.last_key == nil then
		return
	end

	return self.repeatables[self.last_key]:next()
end

function Register:previous()
	if self.last_key == nil then
		return
	end

	return self.repeatables[self.last_key]:previous()
end

function Register:_generate_key()
	return "<Plug>(Register)#" .. #self.repeatables
end

return Register

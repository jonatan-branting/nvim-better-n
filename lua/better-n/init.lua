local Register = require("better-n.register")
local Config = require("better-n.config")

local M = {}

function M.instance()
	if _G.better_n_register ~= nil then
		return _G.better_n_register
	end

	_G.better_n_register = Register:new()

	return _G.better_n_register
end

function M.setup(opts)
	local defaults = Config.get_default_legacy_config()

	if opts.disable_default_mappings then
		defaults.mappings = {}
	end

	opts = vim.tbl_deep_extend("force", defaults, opts)

	Config.apply_legacy_config(opts)

	return M
end

function M.next()
	return M.instance():next()
end

function M.previous()
	return M.instance():previous()
end

function M.n()
	return M.next()
end

function M.shift_n()
	return M.previous()
end

function M.create(...)
	return M.instance():create(...)
end

function M.register(...)
	return M.instance():register(...)
end

return M

local Register = require("better-n.register")
local Config = require("better-n.config")

local M = {}

function M.session()
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
	return M.session():next()
end

function M.previous()
	return M.session():previous()
end

function M.create(...)
	return M.session():create(...)
end

function M.register(...)
	return M.session():register(...)
end

return M

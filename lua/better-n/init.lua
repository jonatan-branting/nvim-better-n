local autocmd = require("better-n.autocmd")
local utils = require("better-n.utils")

local M = {}

M.latest_movement_cmd = {
	key = "/",
}

M.mappings_table = {
	["*"] = { previous = "<s-n>", next = "n" },
	["#"] = { previous = "<s-n>", next = "n" },
	["f"] = { previous = ",", next = ";" },
	["t"] = { previous = ",", next = ";" },
	["F"] = { previous = ",", next = ";" },
	["T"] = { previous = ",", next = ";" },

	["/"] = { previous = "<s-n>", next = "n", cmdline = true },
	["?"] = { previous = "<s-n>", next = "n", cmdline = true },
}

vim.keymap.set({ "n", "x" }, "<Plug>(better-n)n", "n")
vim.keymap.set({ "n", "x" }, "<Plug>(better-n)sn", "<s-n>")

function M.execute_map(map)
	-- TODO do not assume it's bound to n/<s-n>
	if map == "n" or map == "<s-n>" then
		vim.api.nvim_feedkeys(utils.t(vim.v.count1 .. map), "nx", true)
	else
		vim.api.nvim_feedkeys(utils.t(vim.v.count1 .. map), "mx", true)
	end
end

function M.n()
	local key = M.mappings_table[M.latest_movement_cmd.key].next
	if key == "n" then
		return "<Plug>(better-n)n"
	elseif key == "<s-n>" then
		return "<Plug>(better-n)sn"
	else
		return key
	end
end

function M.shift_n()
	local key = M.mappings_table[M.latest_movement_cmd.key].previous
	if key == "n" then
		return "<Plug>(better-n)n"
	elseif key == "<s-n>" then
		return "<Plug>(better-n)sn"
	else
		return key
	end
end

function M.setup_autocmds(callback)
	autocmd.subscribe("MappingExecuted", function(mode, key)
		if callback then
			callback(mode, key)
		end

		M.latest_movement_cmd.key = key
	end)

	vim.api.nvim_create_autocmd("BufEnter", {
		callback = function(data)
			vim.schedule(function()
				M.remap_keys(data.buf)
			end)
		end
	})
end

function M.register_cmdline()
	vim.api.nvim_create_autocmd("CmdlineLeave", {
		callback = function()
			local abort = vim.v.event.abort
			local cmdline_char = vim.fn.expand("<afile>")

			if not abort and utils.has_key(M.mappings_table, cmdline_char) then
				M.set_last_movement_key(cmdline_char)
			end
		end,
	})
end

function M.keymap_from_key(bufnr, mode, key)
	local transformed_key = utils.t(key)

	for _, keymap in ipairs(vim.api.nvim_buf_get_keymap(bufnr, mode)) do
		if keymap.lhs == transformed_key then
			return keymap
		end
	end

	for _, keymap in ipairs(vim.api.nvim_get_keymap(mode)) do
		if keymap.lhs == transformed_key then
			return keymap
		end
	end
end

function M.remap_key(bufnr, mode, key)
	local keymap = M.keymap_from_key(bufnr, mode, key)
	local action = (keymap and (keymap.callback or keymap.rhs)) or key

	-- TODO: there has to be a better way!
	if keymap and keymap.desc == "better-n" then
		return
	end

	vim.keymap.set(mode, key, function()
		autocmd.emit("MappingExecuted", mode, key)

		if type(action) == "function" then
			return action()
		end

		return vim.v.count1 .. action
	end, { buffer = bufnr, expr = type(action) ~= "function", desc = "better-n" })
end

function M.set_last_movement_key(key)
	M.latest_movement_cmd.key = key
end

function M.remap_keys(bufnr)
	for key, mapping in pairs(M.mappings_table) do
		if mapping.cmdline then
			goto continue
		end

		for _, mode in ipairs({ "n", "x" }) do
			M.remap_key(bufnr, mode, key)
		end

		::continue::
	end
end

function M.register_keys()
	if vim.api.nvim_get_current_buf() ~= nil then
		M.remap_keys(vim.api.nvim_get_current_buf())
	end
end

function M.setup(opts)
	for key, value in pairs(opts.mappings or {}) do
		M.mappings_table[key] = value
	end

	M.setup_autocmds(opts.callbacks.mapping_executed)

	M.register_cmdline()
	M.register_keys()
end

return M

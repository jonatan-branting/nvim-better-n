local Config = {}
local P = {}

function Config.get_default_legacy_config()
	return {
		callbacks = {
			mapping_executed = function(_key, _mode)
				-- noop
			end,
		},
		mappings = {
			["/"] = { next = "n", previous = "<s-n>", cmdline = true },
			["?"] = { next = "n", previous = "<s-n>", cmdline = true },
			["#"] = { next = "n", previous = "<s-n>", cmdline = true },
			["*"] = { next = "n", previous = "<s-n>", cmdline = true },
			["f"] = { next = ";", previous = "," },
			["t"] = { next = ";", previous = "," },
			["F"] = { next = ";", previous = "," },
			["T"] = { next = ";", previous = "," },
		},
	}
end

function Config.apply_legacy_config(opts)
	P._setup_mappings(opts.mappings)
	P._setup_autocmds(opts.callbacks)
end

function P._setup_mappings(mappings)
	if not mappings then
		return
	end

	for key, mapping in pairs(mappings) do
		local repeatable = require("better-n").create({
			key = key,
			next = mapping.next,
			previous = mapping.previous,
		})

		if not mapping.cmdline then
			vim.keymap.set({ "n", "x" }, repeatable.key, repeatable.passthrough, { expr = true, silent = true })
		end
	end
end

-- This is only here for temporary backwards compatibility
-- Previously only `mapping_executed` was supported.
function P._setup_autocmds(callbacks)
	if not callbacks.mapping_executed then
		return
	end

	vim.api.nvim_create_autocmd("User", {
		pattern = {
			"BetterNNext",
			"BetterNPrevious",
			"BetterNPassthrough",
		},
		callback = function(args)
			vim.schedule(function()
				callbacks.mapping_executed(args.data.key, args.data.mode)
			end)
		end,
	})
end

return Config

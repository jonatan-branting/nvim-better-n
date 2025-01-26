local Config = {}
local P = {}

function P._setup_default_mappings()
  local better_n = require("better-n")

  local f = better_n.create({ initiate = "f", next = ";", previous = "," })
  vim.keymap.set({ "n", "x" }, "f", f.passthrough, { expr = true, silent = true })

  local F = better_n.create({ initiate = "F", next = ";", previous = "," })
  vim.keymap.set({ "n", "x" }, "F", F.passthrough, { expr = true, silent = true })

  local t = better_n.create({ initiate = "t", next = ";", previous = "," })
  vim.keymap.set({ "n", "x" }, "t", t.passthrough, { expr = true, silent = true })

  local T = better_n.create({ initiate = "T", next = ";", previous = "," })
  vim.keymap.set({ "n", "x" }, "T", T.passthrough, { expr = true, silent = true })

  local asterisk = better_n.create({ initiate = "*", next = "n", previous = "<s-n>" })
  vim.keymap.set({ "n", "x" }, "*", asterisk.passthrough, { expr = true, silent = true })

  local hash = better_n.create({ initiate = "#", next = "n", previous = "<s-n>" })
  vim.keymap.set({ "n", "x" }, "#", hash.passthrough, { expr = true, silent = true })

  vim.keymap.set({ "n", "x" }, "n", better_n.next, { expr = true, silent = true, nowait = true })
  vim.keymap.set({ "n", "x" }, "<s-n>", better_n.previous, { expr = true, silent = true, nowait = true })
end

function P._setup_cmdline_mappings()
  local better_n = require("better-n")

  better_n.create({ id = "/", next = "n", previous = "<s-n>" })
  better_n.create({ id = "?", next = "n", previous = "<s-n>" })
end

function Config.get_default_config()
  return {
    disable_default_mappings = false,
    disable_cmdline_mappings = false,
    -- @deprecated
    callbacks = {
      mapping_executed = nil,
    },
    -- @deprecated
    mappings = {},
  }
end

function Config.apply_config(config)
  if not config.disable_cmdline_mappings then
    P._setup_cmdline_mappings()
  end

  if not config.disable_default_mappings then
    P._setup_default_mappings()
  end
end

return Config

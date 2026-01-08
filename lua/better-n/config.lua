local Config = {}
local P = {}

function P._setup_default_mappings()
  local better_n = require("better-n")

  local f = better_n.create({ passthrough = "f", next = ";", previous = "," })
  vim.keymap.set({ "n", "x", "o" }, "f", f.passthrough, { silent = true, expr = true })

  local F = better_n.create({ passthrough = "F", next = ";", previous = "," })
  vim.keymap.set({ "n", "x", "o" }, "F", F.passthrough, { silent = true, expr = true })

  local t = better_n.create({ passthrough = "t", next = ";", previous = "," })
  vim.keymap.set({ "n", "x", "o" }, "t", t.passthrough, { silent = true, expr = true })

  local T = better_n.create({ passthrough = "T", next = ";", previous = "," })
  vim.keymap.set({ "n", "x", "o" }, "T", T.passthrough, { silent = true, expr = true })

  local asterisk = better_n.create({ passthrough = "*", next = "n", previous = "<s-n>" })
  vim.keymap.set({ "n", "x", "o" }, "*", asterisk.passthrough, { silent = true, expr = true })

  local hash = better_n.create({ passthrough = "#", next = "n", previous = "<s-n>" })
  vim.keymap.set({ "n", "x", "o" }, "#", hash.passthrough, { silent = true, expr = true })

  vim.keymap.set({ "n", "x", "o" }, "n", better_n.next, { silent = true, expr = true, nowait = true })
  vim.keymap.set({ "n", "x", "o" }, "<s-n>", better_n.previous, { silent = true, expr = true, nowait = true })
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

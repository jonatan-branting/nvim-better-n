local Config = {}
local P = {}

function P._setup_default_mappings()
  local better_n = require("better-n")

  better_n.create({ key = "/", next = "n", previous = "<s-n>" })
  better_n.create({ key = "?", next = "n", previous = "<s-n>" })

  local f = better_n.create({ initiate = "f", next = ";", previous = "," })
  vim.keymap.set({ "n", "x" }, "f", f.passthrough_key)

  local F = better_n.create({ initiate = "F", next = ";", previous = "," })
  vim.keymap.set({ "n", "x" }, "F", F.passthrough_key)

  local t = better_n.create({ initiate = "t", next = ";", previous = "," })
  vim.keymap.set({ "n", "x" }, "t", t.passthrough_key, {  silent = true })

  local T = better_n.create({ key = "T", next = ";", previous = "," })
  vim.keymap.set({ "n", "x" }, "T", T.passthrough_key, {  silent = true })

  local asterisk = better_n.create({ initiate = "*", next = "n", previous = "<s-n>" })
  vim.keymap.set({ "n", "x" }, "*", asterisk.passthrough_key, {  silent = true })

  local hash = better_n.create({ initiate = "#", next = "n", previous = "<s-n>" })
  vim.keymap.set({ "n", "x" }, "#", hash.passthrough_key, {  silent = true })

  -- vim.keymap.set({ "n", "x" }, "n", better_n.next, { expr = true, silent = true, nowait = true })
  -- vim.keymap.set({ "n", "x" }, "<s-n>", better_n.previous, {  silent = true, nowait = true })
end

function Config.get_default_config()
  return {
    disable_default_mappings = false,
    -- @deprecated
    callbacks = {
      mapping_executed = nil,
    },
    -- @deprecated
    mappings = {},
  }
end

function Config.apply_config(config)
  if not config.disable_default_mappings then
    P._setup_default_mappings()
  end
end

return Config

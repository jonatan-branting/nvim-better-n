local Config = {}
local P = {}

function P._setup_default_mappings()
  local better_n = require("better-n")

  better_n.listen("f", { next = ";", prev = "," })
  better_n.listen("F", { next = ";", prev = "," })
  better_n.listen("t", { next = ";", prev = "," })
  better_n.listen("T", { next = ";", prev = "," })
  better_n.listen("*", { next = "n", prev = "<s-n>" })
  better_n.listen("#", { next = "n", prev = "<s-n>" })
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

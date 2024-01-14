local Config = {}

function Config.get_default_config()
  return {
    mappings = {
      ["/"] = { next = "n", previous = "<s-n>", cmdline = true },
      ["?"] = { next = "n", previous = "<s-n>", cmdline = true },
      ["#"] = { next = "n", previous = "<s-n>", cmdline = true },
      ["*"] = { next = "n", previous = "<s-n>", cmdline = true },
      ["f"] = { next = ";", previous = "," },
      ["t"] = { next = ";", previous = "," },
      ["F"] = { next = ";", previous = "," },
      ["T"] = { next = ";", previous = "," },
    }
  }
end

function Config.setup_mappings(mappings)
  for key, mapping in pairs(mappings) do
    local repeatable = require("better-n").create({ key = key, next = mapping.next, previous = mapping.previous })

    if not mapping.cmdline then
      vim.keymap.set({ "n", "x" }, repeatable.key, repeatable.passthrough, { expr = true, silent = true })
    end
  end
end

return Config

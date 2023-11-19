local Config = {}

function Config.get_default_mappings()
  return {
    ["/"] = {
      forward = function()
        return "n"
      end,
      backward = function()
        return "<s-n>"
      end
    },
    ["?"] = {
      forward = function()
        return "n"
      end,
      backward = function()
        return "<s-n>"
      end
    }
  }
end

return Config

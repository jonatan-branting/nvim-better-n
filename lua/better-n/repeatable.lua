local Config = require("better-n.config")

local M = {
  generate_uuid =  function()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
      local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
      return string.format('%x', v)
    end)
  end
}

local Repeatable = {}

function Repeatable:new()
  local instance = {
    latest_movement = nil,
    mappings = {}
  }

  setmetatable(instance, self)
  self.__index = self

  vim.api.nvim_create_autocmd("CmdlineLeave", {
    callback = function()
      local abort = vim.v.event.abort
      local cmdline_char = vim.fn.expand("<afile>")

      if not abort and instance.mappings[cmdline_char] ~= nil then
        instance.latest_movement = cmdline_char
      end
    end,
  })

  return instance
end

function Repeatable:setup(config)
  self.latest_movement = "/"
  -- TODO: implement!
  return self
end

function Repeatable:create(opts)
  local forward = opts.forward
  local backward = opts.backward
  local key = opts.key or M.generate_uuid()

  self.mappings[key] = {
    forward = function()
      self.latest_movement = key

      if type(forward) == "function" then
        forward()
        return ""
      else
        return vim.v.count1 .. forward
      end
    end,
    backward = function()
      self.latest_movement = key

      if type(backward) == "function" then
        backward()
        return ""
      else
        return vim.v.count1 .. backward
      end
    end,
    key = key
  }

  return self.mappings[key]
end

function Repeatable:register(opts)
  self:create(opts)

  return self
end

function Repeatable:forward()
  return self.mappings[self.latest_movement].forward()
end

function Repeatable:backward()
  return self.mappings[self.latest_movement].backward()
end

return Repeatable

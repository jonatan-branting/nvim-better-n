local Repeatable = require("better-n.repeatable")

local augroup = vim.api.nvim_create_augroup("BetterN", {})

local Register = {}

function Register:new()
  local instance = {
    last_key = nil,
    repeatables = {},
  }

  setmetatable(instance, self)
  self.__index = self

  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = augroup,
    callback = function()
      local abort = vim.v.event.abort
      local cmdline_char = vim.fn.expand("<afile>")

      if not abort and instance.repeatables[cmdline_char] ~= nil then
        instance.last_key = cmdline_char
      end
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    group = augroup,
    pattern = { "BetterNMappingExecuted" },
    callback = function(args)
      local key = args.data.key

      instance.last_key = key
    end,
  })

  return instance
end

function Register:create(opts)
  local key = opts.key or self:_generate_key()

  self.repeatables[key] = Repeatable:new({
    register = self,
    key = key,
    next = opts.next,
    previous = opts.previous,
  })

  return self.repeatables[key]
end

function Register:next()
  if self.last_key == nil then
    return
  end

  return self.repeatables[self.last_key]:next()
end

function Register:previous()
  if self.last_key == nil then
    return
  end

  return self.repeatables[self.last_key]:previous()
end

function Register:_generate_key()
  return "<Plug>(Register)#" .. self:_num_repeatables()
end

-- Workaround for # only working for array-based tables
function Register:_num_repeatables()
  local count = 0
  for _ in pairs(self.repeatables) do
    count = count + 1
  end

  return count
end

return Register

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
  local number = self:_num_repeatables()
  local key = opts.key or self:_generate_key(number)

  local repeatable = Repeatable:new({
    register = self,
    number = number,
    initiate = opts.initiate,
    key = key,
    next = opts.next,
    previous = opts.previous,
    mode = opts.mode
  })

  vim.keymap.set(
    repeatable.mode,
    repeatable.passthrough_key,
    repeatable.passthrough,
    {
      expr = true,
      silent = true
    }
  )
  vim.keymap.set(
    repeatable.mode,
    repeatable.next_key,
    repeatable.next,
    {
      expr = true,
      silent = true
    }
  )
  vim.keymap.set(
    repeatable.mode,
    repeatable.previous_key,
    repeatable.previous,
    {
      expr = true,
      silent = true
    }
  )

  self.repeatables[key] = repeatable

  return repeatable
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

function Register:_generate_key(number)
  return "<Plug>(better-n-#" .. number .. ")"
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

local Repeatable = require("better-n.repeatable")
local Keymap = require("better-n.lib.keymap")

local augroup = vim.api.nvim_create_augroup("BetterN", {})

local Register = {}

function Register:new()
  local instance = {
    last_repeatable_id = nil,
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
        instance.last_repeatable_id = cmdline_char
      end
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    group = augroup,
    pattern = { "BetterNMappingExecuted" },
    callback = function(args)
      local repeatable_id = args.data.repeatable_id

      instance.last_repeatable_id = repeatable_id
    end,
  })

  return instance
end

function Register:create(opts)
  local repeatable = Repeatable:new({
    register = self,
    bufnr = opts.bufnr or 0,
    next = opts.next,
    previous = opts.previous or opts.prev,
    passthrough = opts.initiate or opts.key or opts.next,
    mode = opts.mode or "n",
    id = opts.id,
  })

  vim.keymap.set(repeatable.mode, repeatable.passthrough_key, repeatable.passthrough, { expr = true, silent = true })
  vim.keymap.set(repeatable.mode, repeatable.next_key, repeatable.next, { expr = true, silent = true })
  vim.keymap.set(repeatable.mode, repeatable.previous_key, repeatable.previous, { expr = true, silent = true })

  self.repeatables[repeatable.id] = repeatable

  return repeatable
end

function Register:create_from_mapping(opts)
  local mode = opts.mode or "n"
  local next_action = opts.next
  local previous_action = opts.previous or opts.prev

  local keymap = Keymap:new({bufnr = opts.bufnr, mode = mode})

  if type(next_action) == "string" then
    next_action = (keymap[next_action] or {}).rhs or next_action
  end

  if type(previous_action) == "string" then
    previous_action = (keymap[previous_action] or {}).rhs or previous_action
  end

  return self:create({ unpack(opts), next = next_action, previous = previous_action, mode = mode})
end

function Register:next()
  if self.last_repeatable_id == nil then
    return
  end

  return self.repeatables[self.last_repeatable_id]:next()
end

function Register:previous()
  if self.last_repeatable_id == nil then
    return
  end

  return self.repeatables[self.last_repeatable_id]:previous()
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

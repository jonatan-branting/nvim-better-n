local Keymap = require("better-n.keymap")

local Repeatable = {}

function Repeatable:new(opts)
  local keymap = Keymap:new({bufnr = opts.bufnr, mode = "n"})
  local instance = {
    register = opts.register or error("opts.register is required" .. vim.inspect(opts)),
    passthrough_action = opts.passthrough or error("opts.passthrough is required" .. vim.inspect(opts)),
    id = opts.id or opts.register:_num_repeatables(),
    mode = opts.mode or { "n" },
    bufnr = opts.bufnr
  }

  setmetatable(instance, self)
  self.__index = self

  instance.passthrough_key = "<Plug>(better-n-#" .. instance.id .. ")"
  instance.next_key = "<Plug>(better-n-#" .. instance.id .. "-next)"
  instance.previous_key = "<Plug>(better-n-#" .. instance.id .. "-previous)"

  local next_action = opts.next or error("opts.next is required" .. vim.inspect(opts))
  local previous_action = opts.previous or error("opts.previous or opts.prev is required" .. vim.inspect(opts))

  -- Extract the actual action from the keymap if it's a string.
  -- This is more robust, and solves some remap issues that can otherwise occur.
  if type(next_action) == "string" then
    next_action = (keymap[next_action] or {}).rhs or next_action
  end

  if type(previous_action) == "string"then
    previous_action = (keymap[previous_action] or {}).rhs or previous_action
  end

  instance.next_action = next_action
  instance.previous_action = previous_action

  instance.next = function()
    return instance:_next()
  end
  instance.previous = function()
    return instance:_previous()
  end
  instance.passthrough = function()
    return instance:_passthrough()
  end

  instance.prev = instance.previous
  instance.prev_key = instance.previous_key

  return instance
end

function Repeatable:_next()
  vim.api.nvim_exec_autocmds("User", {
    pattern = { "BetterNNext", "BetterNMappingExecuted" },
    data = { repeatable_id = self.id, key = self.id, mode = vim.fn.mode() },
  })

  if type(self.next_action) == "function" then
    return vim.schedule(self.next_action)
  else
    return vim.v.count1 .. self.next_action
  end
end

function Repeatable:_previous()
  vim.api.nvim_exec_autocmds("User", {
    pattern = { "BetterNPrevious", "BetterNMappingExecuted" },
    data = { repeatable_id = self.id, key = self.id, mode = vim.fn.mode() },
  })

  if type(self.previous_action) == "function" then
    return vim.schedule(self.previous_action)
  else
    return vim.v.count1 .. self.previous_action
  end
end

function Repeatable:_passthrough()
  vim.api.nvim_exec_autocmds("User", {
    pattern = { "BetterNPassthrough", "BetterNMappingExecuted" },
    data = { repeatable_id = self.id, key = self.id, mode = vim.fn.mode() },
  })

  if type(self.passthrough_action) == "function" then
    return vim.schedule(self.passthrough_action)
  else
    return vim.v.count1 .. self.passthrough_action
  end
end

return Repeatable

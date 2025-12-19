local Repeatable = {}

function Repeatable:new(opts)
  local instance = {}

  setmetatable(instance, self)
  self.__index = self

  instance.id = assert(opts.id)
  instance.bufnr = assert(opts.bufnr)
  instance.mode = opts.mode or "n"
  instance.match = opts.match or function()
    return true
  end

  if type(opts.next_action) == "function" then
    instance.next_action = opts.next_action
  elseif type(opts.next_action) == "string" then
    instance.next_action = function() return opts.next_action end
  else
    error("opts.next_action has to be provided and be a string or a function")
  end

  if type(opts.prev_action) == "function" then
    instance.prev_action = opts.prev_action
  elseif type(opts.prev_action) == "string" then
    instance.prev_action = function() return opts.prev_action end
  else
    error("opts.prev_action has to be provided and be a string or a function")
  end

  instance.expr = opts.expr
  if instance.expr == nil then
    instance.expr = true
  end

  instance.remap = opts.remap
  if instance.remap == nil then
    instance.remap = false
  end

  instance.next_key = "<Plug>(better-n-#" .. instance.id .. "-next)"
  instance.prev_key = "<Plug>(better-n-#" .. instance.id .. "-previous)"

  instance.next = function()
    return instance:_next()
  end
  instance.prev = function()
    return instance:_previous()
  end

  -- Maintain compatibility with previous versions
  instance.previous = instance.prev
  instance.previous_action = instance.prev_action
  instance.previous_key = instance.prev_key

  return instance
end

function Repeatable:_next()
  vim.api.nvim_exec_autocmds("User", {
    pattern = { "BetterNNext", "BetterNMappingExecuted" },
    data = { repeatable_id = self.id, key = self.id, mode = vim.fn.mode() },
  })

  return vim.v.count1 .. (self.next_action() or "<Nop>")
end

function Repeatable:_previous()
  vim.api.nvim_exec_autocmds("User", {
    pattern = { "BetterNPrevious", "BetterNMappingExecuted" },
    data = { repeatable_id = self.id, key = self.id, mode = vim.fn.mode() },
  })

  return vim.v.count1 .. (self.prev_action() or "<Nop>")
end

return Repeatable

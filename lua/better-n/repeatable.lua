local Repeatable = {}

function Repeatable:new(opts)
  local instance = {}

  setmetatable(instance, self)
  self.__index = self

  instance.id = assert(opts.id)
  instance.register = opts.register
  instance.bufnr = assert(opts.bufnr)
  instance.mode = opts.mode or { "x", "n" }
  instance.match = opts.match or function()
    return true
  end

  if type(opts.passthrough_action) == "function" then
    instance.passthrough_action = opts.passthrough_action
  elseif type(opts.passthrough_action) == "string" then
    -- stylua: ignore
    instance.passthrough_action = function() return opts.passthrough_action end
  else
    -- stylua: ignore
    instance.passthrough_action = function() return "<Nop>" end
  end

  if type(opts.next_action) == "function" then
    instance.next_action = opts.next_action
  elseif type(opts.next_action) == "string" then
    -- stylua: ignore
    instance.next_action = function() return opts.next_action end
    instance.expr = true
  else
    error("opts.next_action has to be provided and be a string or a function")
  end

  if type(opts.prev_action) == "function" then
    instance.prev_action = opts.prev_action
  elseif type(opts.prev_action) == "string" then
    -- stylua: ignore
    instance.prev_action = function() return opts.prev_action end
    instance.expr = true
  else
    error("opts.prev_action has to be provided and be a string or a function")
  end

  instance.expr = type(opts.expr) == "boolean" and opts.expr or instance.expr
  instance.remap = type(opts.remap) == "boolean" and opts.remap or false

  instance.next_key = "<Plug>(better-n-#" .. instance.id .. "-next)"
  instance.prev_key = "<Plug>(better-n-#" .. instance.id .. "-previous)"
  instance.passthrough_key = "<Plug>(better-n-#" .. instance.id .. "-passthrough)"

  -- stylua: ignore start
  instance.next = function() return instance:_next() end
  instance.prev = function() return instance:_previous() end
  instance.passthrough = function() return instance:_passthrough() end
  -- stylua: ignore end

  -- stylua: ignore start
  vim.keymap.set(instance.mode, instance.next_key, instance.next, { expr = instance.expr, remap = instance.remap, silent = true })
  vim.keymap.set(instance.mode, instance.prev_key, instance.prev, { expr = instance.expr, remap = instance.remap, silent = true })
  vim.keymap.set(instance.mode, instance.passthrough_key, instance.passthrough, { expr = instance.expr, remap = instance.remap, silent = true })
  -- stylua: ignore end

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

  local action = self.next_action(vim.v.count1) or "<Nop>"
  local count = action:match("^(%d+)") or vim.v.count1
  action = action:gsub("^(%d+)", "")

  return count .. action
end

function Repeatable:_previous()
  vim.api.nvim_exec_autocmds("User", {
    pattern = { "BetterNPrevious", "BetterNMappingExecuted" },
    data = { repeatable_id = self.id, key = self.id, mode = vim.fn.mode() },
  })

  local action = self.prev_action(vim.v.count1) or "<Nop>"
  local count = action:match("^(%d+)") or vim.v.count1
  action = action:gsub("^(%d+)", "")

  return count .. action
end

function Repeatable:_passthrough()
  vim.api.nvim_exec_autocmds("User", {
    pattern = { "BetterNAction", "BetterNMappingExecuted" },
    data = { repeatable_id = self.id, key = self.id, mode = vim.fn.mode() },
  })

  local action = self.passthrough_action(vim.v.count1) or "<Nop>"
  local count = action:match("^(%d+)") or vim.v.count1
  action = action:gsub("^(%d+)", "")

  return count .. action
end

return Repeatable

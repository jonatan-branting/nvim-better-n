local Repeatable = {}

function Repeatable:new(opts)
  local instance = {}

  setmetatable(instance, self)
  self.__index = self

  instance.id = assert(opts.id)
  instance.mode = assert(opts.mode)
  instance.bufnr = assert(opts.bufnr)
  instance.next_action = assert(opts.next_action)
  instance.prev_action = assert(opts.prev_action)

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

return Repeatable

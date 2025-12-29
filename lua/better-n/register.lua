local Repeatable = require("better-n.repeatable")

local augroup = vim.api.nvim_create_augroup("BetterN", {})
local ns_id = vim.api.nvim_create_namespace("BetterN")

local Register = {}

function Register:new()
  local instance = {
    last_repeatable_id = nil,
    last_repeatable_captures = nil,
    repeatables = {},
    repeatables_by_pattern = {},
    type_buffer = "",
  }

  setmetatable(instance, self)
  self.__index = self

  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = augroup,
    callback = function(args)
      local abort = vim.v.event.abort
      local cmdline_char = vim.fn.expand("<afile>")

      if not abort and instance.repeatables[cmdline_char] ~= nil then
        instance.last_repeatable_id = cmdline_char
        return
      end

      if #instance.type_buffer == 0 then
        return
      end

      print("Buffer", instance.type_buffer)
      local repeatable, captures = instance:find_repeatable_by_pattern(instance.type_buffer)

      instance.type_buffer = ""

      if repeatable ~= nil then
        instance.last_repeatable_id = repeatable.id
        instance.last_repeatable_captures = captures
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

  -- Setup key listening for `#listen`
  local safestate_augroup = vim.api.nvim_create_augroup("BetterNSafeState", { clear = true })
  vim.on_key(function(_, typed)
    if typed == "" then
      return
    end

    if vim.fn.mode() == "i" then
      return
    end

    if vim.fn.mode() == "c" then
      instance.type_buffer = instance.type_buffer .. typed

      return
    end

    instance.type_buffer = instance.type_buffer .. typed

    vim.api.nvim_create_autocmd("SafeState", {
      group = safestate_augroup,
      callback = function(_)
        if vim.fn.mode() == "c" then
          return
        end

        if #instance.type_buffer == 0 then
          return
        end

        local repeatable, captures = instance:find_repeatable_by_pattern(instance.type_buffer)

        instance.type_buffer = ""

        if repeatable ~= nil then
          instance.last_repeatable_id = repeatable.id
          instance.last_repeatable_captures = captures
        end
      end,
      once = true,
    })
  end, ns_id, {})

  return instance
end

function Register:create(opts)
  local repeatable = Repeatable:new({
    id = opts.id or self:_num_repeatables() + 1,
    bufnr = opts.bufnr or 0,
    passthrough_action = opts.passthrough,
    next_action = opts.next_action or opts.next,
    prev_action = opts.prev_action or opts.prev or opts.previous,
    mode = opts.mode,
    expr = opts.expr,
    remap = opts.remap,
    match = opts.match,
    register = self,
  })

  self.repeatables[repeatable.id] = repeatable

  return repeatable
end

function Register:listen(pattern, opts)
  assert(type(pattern) == "string", "pattern has to be a string representing a Lua pattern")

  pattern = "^" .. pattern .. "$"
  local repeatable = Repeatable:new({
    id = pattern,
    bufnr = opts.bufnr or 0,
    next_action = opts.next_action or opts.next,
    prev_action = opts.prev_action or opts.prev or opts.previous,
    mode = opts.mode,
    expr = opts.expr,
    remap = opts.remap,
    match = opts.match,
    register = self,
  })

  self.repeatables[repeatable.id] = repeatable
  self.repeatables_by_pattern[pattern] = repeatable

  return repeatable
end

function Register:find_repeatable_by_pattern(str)
  local repeatable = nil
  local captures = nil

  for pattern, r in pairs(self.repeatables_by_pattern) do
    captures = { str:match(pattern) }

    if #captures > 0 and r.match(unpack(captures)) then
      self.last_repeatable_captures = captures
      repeatable = r

      break
    end
  end

  return repeatable, captures
end

function Register:next()
  if self.last_repeatable_id == nil then
    return
  end

  return self.repeatables[self.last_repeatable_id].next_key
end

function Register:previous()
  if self.last_repeatable_id == nil then
    return
  end

  return self.repeatables[self.last_repeatable_id].prev_key
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

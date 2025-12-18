local Repeatable = require("better-n.repeatable")

local augroup = vim.api.nvim_create_augroup("BetterN", {})
local ns_id = vim.api.nvim_create_namespace("BetterN")

local Register = {}

function Register:new()
  local instance = {
    last_repeatable_id = nil,
    repeatables = {},
    repeatables_by_key = {},
    type_buffer = ""
  }

  setmetatable(instance, self)
  self.__index = self

  local safestate_augroup = vim.api.nvim_create_augroup("BetterNSafeState", { clear = true })

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

  vim.on_key(
    function(_, typed)
      instance.type_buffer = instance.type_buffer .. typed

      vim.api.nvim_create_autocmd("SafeState", {
        group = safestate_augroup,
        callback = function(_)
          local repeatable = nil
          for i = #instance.type_buffer, 1, -1 do
            local key = instance.type_buffer:sub(1, i)
            repeatable = instance.repeatables_by_key[key]

            if repeatable ~= nil then
              break
            end
          end

          instance.type_buffer = ""

          if repeatable ~= nil then
            instance.last_repeatable_id = repeatable.id
          end
        end,
        once = true
      })
    end,
    ns_id,
    {}
  )

  return instance
end

function Register:create(opts)
  local repeatable = Repeatable:new({
    id = opts.id or self:_num_repeatables() + 1,
    bufnr = opts.bufnr or 0,
    next_action = opts.next,
    prev_action = opts.previous or opts.prev,
    mode = opts.mode or "n",
  })

  vim.keymap.set(repeatable.mode, repeatable.next_key, repeatable.next, { expr = true, silent = true })
  vim.keymap.set(repeatable.mode, repeatable.prev_key, repeatable.prev, { expr = true, silent = true })

  self.repeatables[repeatable.id] = repeatable

  return repeatable
end

function Register:listen(key, opts)
  local repeatable = Repeatable:new({
    id = key or self:_num_repeatables() + 1,
    bufnr = opts.bufnr or 0,
    next_action = opts.next,
    prev_action = opts.previous or opts.prev,
    mode = opts.mode or "n",
  })

  self.repeatables[repeatable.id] = repeatable
  self.repeatables_by_key[key] = repeatable

  return repeatable
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

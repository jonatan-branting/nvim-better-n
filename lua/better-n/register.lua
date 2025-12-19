local Repeatable = require("better-n.repeatable")

local augroup = vim.api.nvim_create_augroup("BetterN", {})
local ns_id = vim.api.nvim_create_namespace("BetterN")

local Register = {}

function Register:new()
  local instance = {
    last_repeatable_id = nil,
    repeatables = {},
    repeatables_by_pattern = {},
    type_buffer = ""
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


  -- Setup key listening for `#listen`
  local safestate_augroup = vim.api.nvim_create_augroup("BetterNSafeState", { clear = true })
  vim.on_key(
    function(_, typed)
      if typed == "" then
        return
      end

      instance.type_buffer = instance.type_buffer .. typed

      vim.api.nvim_create_autocmd("SafeState", {
        group = safestate_augroup,
        callback = function(_)
          if #instance.type_buffer == 0 then
            return
          end

          local repeatable = nil
          for pattern, r in pairs(instance.repeatables_by_pattern) do
            local captures = { instance.type_buffer:match(pattern) }

            if #captures > 0 and r.match(unpack(captures)) then
              repeatable = r

              break
            end
          end

          instance.type_buffer = ""

          if repeatable ~= nil then
            print("BetterN: Matched repeatable with pattern '" .. repeatable.id .. "'")
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
    next_action = opts.next_action or opts.next,
    prev_action = opts.prev_action or opts.prev or opts.previous,
    mode = opts.mode,
    expr = opts.expr,
    remap = opts.remap,
    match = opts.match
  })

  vim.keymap.set(repeatable.mode, repeatable.next_key, repeatable.next, { expr = repeatable.expr, remap = repeatable.remap, silent = true })
  vim.keymap.set(repeatable.mode, repeatable.prev_key, repeatable.prev, { expr = repeatable.expr, remap = repeatable.remap, silent = true })

  self.repeatables[repeatable.id] = repeatable

  return repeatable
end

function Register:listen(pattern, opts)
  opts["id"] = pattern

  local repeatable = self:create(opts)

  self.repeatables_by_pattern[pattern] = repeatable

  return repeatable
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

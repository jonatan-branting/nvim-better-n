local autocmd = require("better-n.autocmd")
local utils = require("better-n.utils")

local mapping_prefix = "<plug>(better-n)"

local latest_movement_cmd = {
  mode = "n",
  key = "n"
}

local mappings_table = {
  ["*"] = {previous = "<s-n>", next = "n"},
  ["#"] = {previous = "<s-n>", next = "n"},
  ["f"] = {previous = ",", next = ";"},
  ["t"] = {previous = ",", next = ";"},
  ["F"] = {previous = ",", next = ";"},
  ["T"] = {previous = ",", next = ";"},

  ["/"] = {previous = "<s-n>", next = "n", cmdline = true},
  ["?"] = {previous = "<s-n>", next = "n", cmdline = true},
}

local execute_map = function(map)
  vim.api.nvim_feedkeys(utils.t(vim.v.count1 .. mapping_prefix .. map), latest_movement_cmd.mode, false)
end

local n = function()
  execute_map(mappings_table[latest_movement_cmd.key].next)
end

local shift_n = function()
  execute_map(mappings_table[latest_movement_cmd.key].previous)
end

local setup_autocmds = function(callback)
  autocmd.subscribe("MappingExecuted", function(mode, key)
    if callback then callback(mode, key) end

    latest_movement_cmd.mode = mode
    latest_movement_cmd.key = key
  end)
end

local register_cmdline = function()
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    callback = function()
      local abort = vim.v.event.abort
      local cmdline_char = vim.fn.expand("<afile>")

      if not abort and utils.has_key(mappings_table, cmdline_char) then
        autocmd.emit("MappingExecuted", "n", cmdline_char)
      end
    end
  })
end

local action_from_key = function(mode, key)
  local transformed_key = utils.t(key)

  for _, keymap in pairs(vim.api.nvim_get_keymap(mode)) do
    if keymap.lhs == transformed_key then
      return keymap.callback or keymap.rhs
    end
  end
end

local register_key = function(mode, key)
  -- TODO doesn't support buffer local mappings properly.

  -- Store the original keymap in a <plug>(better-n) keybind, so we can reuse the
  -- functionality
  local action = action_from_key(mode, key) or key
  vim.keymap.set(mode, mapping_prefix .. key, action, {silent = true})

  vim.keymap.set(mode, key, function()
    autocmd.emit("MappingExecuted", mode, key)

    vim.api.nvim_feedkeys(utils.t(vim.v.count1 .. mapping_prefix .. key), mode, false)
  end)
end

local register_keys = function()
  for key, mapping in pairs(mappings_table) do
    if mapping.cmdline then goto continue end

    for _, mode in ipairs({ "n", "v" }) do
      register_key(mode, key)
    end

    ::continue::
  end
end

local store_baseline_keys = function()
  -- Save important keybinds in <plug> bindings, for reuse
  for _, key in ipairs({ ";", ",", "n", "<s-n>" }) do
    for _, mode in ipairs({ "n", "v" }) do
      vim.keymap.set(mode,  mapping_prefix .. key, key, {silent = true, nowait = true})
    end
  end
end

local setup = function(opts)
  for key, value in pairs(opts.mappings or {}) do
    mappings_table[key] = value
  end

  setup_autocmds(opts.callbacks.mapping_executed)

  store_baseline_keys()

  register_cmdline()
  register_keys()
end

return {
  setup = setup,
  n = n,
  shift_n = shift_n,
}

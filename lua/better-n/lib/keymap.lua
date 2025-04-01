local Enumerable = require("better-n.lib.enumerable")

local Keymap = {}

function Keymap:new(opts)
  local instance = {
    bufnr = opts.bufnr,
    mode = opts.mode or "n",
  }

  local raw_keymap = instance.bufnr and
    vim.api.nvim_buf_get_keymap(instance.bufnr, instance.mode) or
    vim.api.nvim_get_keymap(instance.mode)

  instance.keymap = Enumerable:new(raw_keymap)
  setmetatable(instance, Keymap)

  return instance
end

Keymap.__index = function(self, key)
  -- Support accessing instance variables directly
  local class_value = rawget(self, key)
  if class_value ~= nil then
    return class_value
  end

  -- Ensure it has the expected casing and format
  local transformed_key = vim.fn.keytrans(vim.keycode(key))
  local keymap = rawget(self, "keymap")

  return keymap:find(function(mapping)
    return mapping.lhs == transformed_key
  end)
end

return Keymap


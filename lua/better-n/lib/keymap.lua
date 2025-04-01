local Enumerable = require("better-n.lib.enumerable")

local Keymap = {}

function Keymap:new(opts)
  local instance = {
    bufnr = opts.bufnr or 0,
    mode = opts.mode or "n",
  }

  local buffer_mappings = vim.api.nvim_buf_get_keymap(instance.bufnr, instance.mode)
  local global_mappings = vim.api.nvim_get_keymap(instance.mode)

  local mappings = Enumerable:new(buffer_mappings)
  for _, mapping in ipairs(global_mappings) do
    mappings:append(mapping)
  end

  instance.mappings = mappings

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
  local keycode = vim.keycode(key)
  local mappings = rawget(self, "mappings")

  return mappings:find(function(mapping)
    return vim.keycode(mapping.lhs) == keycode
  end)
end

return Keymap


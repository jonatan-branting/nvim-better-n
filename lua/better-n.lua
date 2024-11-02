local Register = require("better-n.register")
local Config = require("better-n.config")

local M = {}

function M.instance()
  if _G.better_n_register ~= nil then
    return _G.better_n_register
  end

  _G.better_n_register = Register:new()

  return _G.better_n_register
end

function M.setup(opts)
  if opts.mappings then
    vim.deprecate(
      "opts.mappings is deprecated",
      'create mappings manually using `require("better-n").create({ next = ..., previous = ... })`',
      "HEAD",
      "nvim-better-n",
      false
    )
  end
  if opts.callbacks then
    vim.deprecate(
      "opts.callbacks",
      "Use `vim.api.nvim_create_autocmd` to listen to the User event with pattern `BetterNMappingExecuted` instead",
      "HEAD",
      "nvim-better-n",
      false
    )
  end
  local defaults = Config.get_default_config()
  local config = vim.tbl_deep_extend("force", defaults, opts)

  Config.apply_config(config)

  return M
end

function M.next()
  return M.instance():next()
end

function M.previous()
  return M.instance():previous()
end

function M.n()
  return M.next()
end

function M.shift_n()
  return M.previous()
end

function M.create(...)
  return M.instance():create(...)
end

return M

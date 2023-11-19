local Enumerable = require("lib.enumerable")

local Buffer = {}

function Buffer.current()
  return Buffer:new(vim.api.nvim_get_current_buf())
end

function Buffer.all()
  return Enumerable:new(vim.api.nvim_list_bufs()):map(function(bufnr)
    return Buffer:new(bufnr)
  end)
end

function Buffer:new(bufnr)
  local instance = {
    bufnr = bufnr,
  }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

function Buffer:windows()
  local Window = require("window")

  return Enumerable:new(vim.api.nvim_list_wins())
  :select(function(winnr)
    return vim.api.nvim_win_get_buf(winnr) == self.bufnr
  end)
  :map(function(winnr)
    return Window:new(winnr)
  end)
end

function Buffer:open()
  return vim.api.nvim_set_current_buf(self.bufnr)
end

return Buffer

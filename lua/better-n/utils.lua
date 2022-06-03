local M = {}

function M.t(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

function M.has_key(table, _key)
  for key, _ in pairs(table) do
    if key == _key then
      return true
    end
  end

  return false
end

return M

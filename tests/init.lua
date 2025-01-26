local cwd = vim.fn.getcwd()

vim.opt.swapfile = false

vim.api.nvim_command([[set rtp+=.]])
vim.api.nvim_command(
  string.format([[set rtp+=%s/lua_modules/lib/lua/5.1/,%s/tests/]], cwd, cwd)
)
vim.api.nvim_command([[packloadall]])

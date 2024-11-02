local cwd = vim.fn.getcwd()

vim.opt.swapfile = false

vim.api.nvim_command([[set rtp+=.]])
vim.api.nvim_command(
  string.format([[set rtp+=%s/lua_modules/lib/lua/5.1/,%s/tests/,%s/tests/better-n/]], cwd, cwd, cwd)
)
vim.api.nvim_command([[packloadall]])

local better_n = require("better-n")
better_n.setup({})

vim.keymap.set({ "n", "x" }, "n", better_n.next, { nowait = true, remap = true, expr = true })
vim.keymap.set({ "n", "x" }, "<s-n>", better_n.previous, { nowait = true, remap = true, expr = true })

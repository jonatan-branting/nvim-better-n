local M = {}

function M.feed(text, feed_opts)
  feed_opts = feed_opts or "mtx"
  local to_feed = vim.api.nvim_replace_termcodes(text, true, false, true)

  vim.api.nvim_feedkeys(to_feed, feed_opts, false)
end

function M.setup_buffer(input, filetype)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "filetype", filetype)
  vim.api.nvim_command("buffer " .. buf)

  vim.api.nvim_buf_set_lines(0, 0, -1, true, input)

  return buf
end

function M.get_buf_lines()
  return vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
end

function M.script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match(("(.*%s)"):format("/"))
end

function M.t(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

return M

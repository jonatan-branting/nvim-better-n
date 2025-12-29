local t = require("../helper")
local better_n = require("better-n")

better_n.setup({ disable_default_mappings = true })

vim.keymap.set({ "n", "x" }, "n", better_n.next, { expr = true })
vim.keymap.set({ "n", "x" }, "<s-n>", better_n.prev, { expr = true })

describe("mapping with pattern", function()
  before_each(function()
    -- listen
    better_n.listen("(%d-)f", { next = ";", prev = "," })

    -- listen with captures groups
    better_n.listen(
      "(%d-)l",
      {
        match = function(d)
          return (tonumber(d) or 1) >= 5
        end,
        next = "5l",
        prev = "5h"
      }
    )

    -- default buffer
    t.setup_buffer({
      "1234567890 foo bar baz",
    }, "lua")
  end)

  it("can repeat registered movements", function()
    t.feed("7l")
    t.feed("n")
    t.feed("i|")

    local result = t.get_buf_lines()

    assert.are.same({
      "1234567890 foo| bar baz",
    }, result)
  end)
end)

-- describe("feature", function()
--   before_each(function()
--     t.setup_buffer({
--       " atest atext arow",
--       " atest atext arow",
--     }, "lua")
--   end)
--
--   it("can repeat registered movements", function()
--     t.feed("fa")
--     t.feed("n")
--     t.feed("ciwTEXT")
--
--     local result = t.get_buf_lines()
--
--     assert.are.same({
--       " atest TEXT arow",
--       " atest atext arow",
--     }, result)
--   end)
--
--   it("does not interfere with f-movements", function()
--     t.feed("fa")
--     t.feed("n")
--     t.feed("ciwTEXT")
--
--     local result = t.get_buf_lines()
--
--     assert.are.same({
--       " atest TEXT arow",
--       " atest atext arow",
--     }, result)
--   end)
--
--   it("does not interfere with the replaying of macros", function()
--     t.feed("qq")
--
--     t.feed("fa")
--     t.feed("n")
--     t.feed("ciwTEXT")
--
--     t.feed("<esc>")
--     t.feed("q")
--
--     t.feed("j0")
--     t.feed("@q")
--
--     local result = t.get_buf_lines()
--
--     assert.are.same({
--       " atest TEXT arow",
--       " atest TEXT arow",
--     }, result)
--   end)
--
--   it("does not interfere with the 'normal' command", function()
--     t.feed(":1,2normal fanciwTEXT<cr>")
--
--     local result = t.get_buf_lines()
--
--     assert.are.same({
--       " atest TEXT arow",
--       " atest TEXT arow",
--     }, result)
--   end)
-- end)

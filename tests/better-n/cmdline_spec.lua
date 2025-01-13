local t = require("../helper")
local better_n = require("better-n")

better_n.setup({})
vim.keymap.set({ "n", "x" }, "n", better_n.next, { nowait = true, remap = true, expr = true })
vim.keymap.set({ "n", "x" }, "<s-n>", better_n.previous, { nowait = true, remap = true, expr = true })

describe("macros", function()
  before_each(function()
    t.setup_buffer({
      " atest atext arow",
      " atest atext arow",
    }, "lua")
  end)

  it("can repeat registered movements", function()
    t.feed("fa")
    t.feed("n")
    t.feed("ciwTEXT")

    local result = t.get_buf_lines()

    assert.are.same({
      " atest TEXT arow",
      " atest atext arow",
    }, result)
  end)

  it("does not interfere with f-movements", function()
    t.feed("fa")
    t.feed("n")
    t.feed("ciwTEXT")

    local result = t.get_buf_lines()

    assert.are.same({
      " atest TEXT arow",
      " atest atext arow",
    }, result)
  end)

  it("does not interfere with the replaying of macros", function()
    t.feed("qq")

    t.feed("fa")
    t.feed("n")
    t.feed("ciwTEXT")

    t.feed("<esc>")
    t.feed("q")

    t.feed("j0")
    t.feed("@q")

    local result = t.get_buf_lines()

    assert.are.same({
      " atest TEXT arow",
      " atest TEXT arow",
    }, result)
  end)

  it("does not interefere with the 'normal' command", function()
    t.feed(":1,2normal fanciwTEXT<cr>")

    local result = t.get_buf_lines()

    assert.are.same({
      " atest TEXT arow",
      " atest TEXT arow",
    }, result)
  end)
end)

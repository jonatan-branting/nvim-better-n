local t = require("../helper")
local better_n = require("better-n")

better_n.setup({ disable_default_mappings = true })

vim.keymap.set({ "n", "x" }, "n", better_n.next, { expr = true })
vim.keymap.set({ "n", "x" }, "<s-n>", better_n.prev, { expr = true })

describe("listen", function()
  before_each(function()
    _G.better_n_register = nil

    -- listen
    better_n.listen("(%d-)f", { next = ";", prev = "," })

    -- listen with captures groups
    better_n.listen("(%d-)l", {
      match = function(d)
        return (tonumber(d) or 1) >= 5
      end,
      next = "5l",
      prev = "5h",
    })

    -- default buffer
    t.setup_buffer({
      "1234567890 foo bar baz",
    }, "lua")
  end)

  it("can repeat registered movements that match", function()
    t.feed("5l")
    t.feed("n")
    t.feed("i|")

    local result = t.get_buf_lines()

    assert.are.same({
      "1234567890| foo bar baz",
    }, result)
  end)

  it("does not repeat registered movements that do not match", function()
    t.feed("4l") -- Less than 5
    t.feed("n")
    t.feed("i|")

    local result = t.get_buf_lines()

    assert.are.same({
      "1234|567890 foo bar baz",
    }, result)
  end)

  it("works in macros", function()
    t.feed("qq")

    t.feed("5l")
    t.feed("n")
    t.feed("i|")

    t.feed("<esc>")
    t.feed("q")

    t.feed("0")
    t.feed("@q")

    local result = t.get_buf_lines()

    assert.are.same({
      "1234567890|| foo bar baz",
    }, result)
  end)
end)

describe("create", function()
  before_each(function()
    _G.better_n_register = nil

    local f = better_n.create({ passthrough = "f", next = ";", previous = "," })
    vim.keymap.set({ "n", "x" }, "f", f.passthrough, { expr = true })

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

  it("works in macros", function()
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

  it("works with the normal command", function()
    t.feed(":1,2normal fanciwTEXT<cr>")

    local result = t.get_buf_lines()

    assert.are.same({
      " atest TEXT arow",
      " atest TEXT arow",
    }, result)
  end)
end)

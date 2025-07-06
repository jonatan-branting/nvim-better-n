local t = require("../helper")
local better_n = require("better-n")

better_n.setup({})
vim.keymap.set({ "n", "x" }, "n", better_n.next, { nowait = true, expr = true })
vim.keymap.set({ "n", "x" }, "<s-n>", better_n.previous, { nowait = true, expr = true })

-- Existing mapping we'll test against
vim.keymap.set({ "n" }, "))", "f(")
vim.keymap.set({ "n" }, "((", "f)")

describe("#create_from_mapping", function()
  before_each(function()
    t.setup_buffer({
      "print('line 1')",
    }, "lua")
  end)

  it("registers repeatable version of existing mapping", function()
    local paren = better_n.create_from_mapping({ next = "))", prev = "((" })
    vim.keymap.set({ "n" }, "]]", paren.next_key, { expr = true, silent = true })
    vim.keymap.set({ "n" }, "[[", paren.prev_key, { expr = true, silent = true })

    t.feed("))")

    assert.same({ 1, 5 }, vim.api.nvim_win_get_cursor(0))
  end)

  it("registers the mapping to <nop> if mapping doesn't exist", function()
    local missing_mapping = better_n.create_from_mapping( { next = ")}", prev = "({", })

    assert.equal("<Nop>", missing_mapping.next_action)
    assert.equal("<Nop>", missing_mapping.previous_action)
  end)
end)

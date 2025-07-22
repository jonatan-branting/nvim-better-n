local t = require("../helper")
local better_n = require("better-n")

better_n.setup({})
vim.keymap.set({ "n", "x" }, "n", better_n.next, { nowait = true, expr = true })
vim.keymap.set({ "n", "x" }, "<s-n>", better_n.previous, { nowait = true, expr = true })

-- Existing mapping we'll test against
vim.keymap.set({ "n" }, "<Plug>(better-n-test-next)", "f)", { expr = true })
vim.keymap.set({ "n" }, "<Plug>(better-n-test-prev)", "f(", { expr = true })

describe("#create_from_mapping", function()
  before_each(function()
    t.setup_buffer({
      "print('line 1')",
    }, "lua")
  end)

  it("registers repeatable version of existing mapping", function()
    local paren = better_n.create_from_mapping({ next = "<Plug>(better-n-test-next)", prev = "<Plug>(better-n-test-prev)" })
    vim.keymap.set({ "n" }, "gnp", paren.next_key)
    vim.keymap.set({ "n" }, "gpp", paren.prev_key)

    t.feed("0gnp")
    t.feed("i|")

    assert.are.same({
      "print('line 1'|)",
    }, t.get_buf_lines())
  end)

  it("registers the mapping to <Nop> if mapping doesn't exist", function()
    local missing_mapping = better_n.create_from_mapping( { next = ")}", prev = "({", })

    assert.equal("<Nop>", missing_mapping.next_action)
    assert.equal("<Nop>", missing_mapping.previous_action)
  end)
end)

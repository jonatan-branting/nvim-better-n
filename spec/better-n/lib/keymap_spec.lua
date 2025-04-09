local Keymap = require("better-n.lib.keymap")

describe("__index", function()
  it("should return the correct mapping for a given key", function()
    vim.keymap.set("n", "<C-a>", "<cmd>test-keymap<cr>")
    local keymap = Keymap:new({ bufnr = nil, mode = "n" })
    local mapping = keymap["<C-A>"]

    assert.is_not_nil(mapping)
    assert.are.equal("<C-A>", mapping.lhs)
    assert.are.equal("<Cmd>test-keymap<CR>", mapping.rhs)
  end)

  it("should return the correct mapping for a given key bound for a specific buffer", function()
    vim.keymap.set("n", "]]", "<cmd>another-test-keymap<cr>", { buffer = 0 })
    local keymap = Keymap:new({ bufnr = 0, mode = "n" })
    local mapping = keymap["]]"]

    assert.is_not_nil(mapping)
    assert.are.equal("]]", mapping.lhs)
    assert.are.equal("<Cmd>another-test-keymap<CR>", mapping.rhs)
  end)

  it("should return nil for a non-existent key", function()
    local keymap = Keymap:new({ bufnr = 0, mode = "n" })
    local mapping = keymap["<C-x>"]

    assert.is_nil(mapping)
  end)
end)

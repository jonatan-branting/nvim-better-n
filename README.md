# nvim-better-n
Repeat movement commands using `n` in the same vein that `.` repeats action commands.

## About
`nvim-better-n` attempts address a problem with Vim, which is that almost every
single binding is used by default, for (often) very niche actions. I want to be
able to reuse convenient bindings for similar things, reducing both mental
overhead as well as opening up more bindings, allowing Vim to be more
ergonomic.

It does this by rebinding `n` (which is a rather convenient binding), so that
it used for multiple different movement commands, in the same vein `.` repeats
action commands.

For example, if we jump to the next hunk, using `<leader>hn`, we can repeat
that command using `n`, allowing for far easier "scrolling" using that motion
without coming up with a bind that is easier to repeat.

Using this binding for that motion would, without this plugin, be rather
cumbersome in the cases were you wanted to press it multiple times.

It should also be noted that this frees up both `;`, and `,` for other actions,
as `n` will instead handle their current task.

## Install
Install as usual, using your favourite plugin manager.

```lua
use "jonatan-branting/nvim-better-n"
```

## Setup

```lua
require("better-n").setup {
  callbacks = {
    mapping_executed = function(_mode, _key)
      -- Clear highlighting, indicating that `n` will not goto the next
      -- highlighted search-term
      vim.cmd [[ nohl ]]
    end
  },
  mappings = {
    -- I want `n` to always go forward, and `<s-n>` to always go backwards
    ["#"] = {previous = "n", next ="<s-n>"},
    ["F"] = {previous = ";", next = ","},
    ["T"] = {previous = ";", next = ","},

    -- Setting `cmdline = true` ensures that `n` will only be 
    -- overwritten if the search command is succesfully executed
    ["?"] = {previous = "n", next ="<s-n>", cmdline = true},

    -- I have <leader>hn/hp bound to git-hunk-next/prev
    ["<leader>hn"] = {previous = "<leader>hp", next = "<leader>hn"},
    ["<leader>hp"] = {previous = "<leader>hp", next = "<leader>hn"},

    -- I have <leader>bn/bp bound to buffer-next/prev
    ["<leader>bn"] = {previous = "<leader>bp", next = "<leader>bn"},
    ["<leader>bp"] = {previous = "<leader>bp", next = "<leader>bn"},
  }
}

-- You will have to rebind `n` yourself
vim.keymap.set("n", "n", require("better-n").n, {nowait = true})
vim.keymap.set("n", "<s-n>", require("better-n").shift_n, {nowait = true})
```

## Defaults
By default, `nvim-better-n` maps the following bindings:

```lua
local mappings_table = {
  ["*"] = {previous = "<s-n>", next = "n"},
  ["#"] = {previous = "<s-n>", next = "n"},
  ["f"] = {previous = ",", next = ";"},
  ["t"] = {previous = ",", next = ";"},
  ["F"] = {previous = ",", next = ";"},
  ["T"] = {previous = ",", next = ";"},

  ["/"] = {previous = "<s-n>", next = "n", cmdline = true},
  ["?"] = {previous = "<s-n>", next = "n", cmdline = true},
}
```

These can of course be overwritten as wanted.

# nvim-better-n
Repeat movement commands using `n` in the same vein that `.` repeats action commands.

<div align="center">
	<img src="https://user-images.githubusercontent.com/985954/171856362-3e5feda1-8869-4512-bc78-7bdff2b4b3dd.gif" width=900>
</div>

## About
`nvim-better-n` attempts address a problem with Vim, which is that almost every
single binding is used by default, for (often) very niche actions. I want to be
able to reuse convenient bindings for similar things, reducing both mental
overhead as well as opening up more bindings, allowing Vim to be more
ergonomic.

It does this by rebinding `n` (which is a rather convenient binding), so that
it used for multiple different movement commands, in the same vein `.` repeats
action commands.

For example, if we jump to the next hunk, using `]h`, we can repeat
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
require("better-n").setup(
  {
    -- These will be bound on load
    mappings = {
      ["/"] = { next = "n", previous = "<s-n>", cmdline = true },
      ["?"] = { next = "n", previous = "<s-n>", cmdline = true },
      ["#"] = { next = "n", previous = "<s-n>", cmdline = true },
      ["*"] = { next = "n", previous = "<s-n>", cmdline = true },
      ["f"] = { next = ";", previous = "," },
      ["t"] = { next = ";", previous = "," },
      ["F"] = { next = ";", previous = "," },
      ["T"] = { next = ";", previous = "," },
    },
  }
)

vim.nvim_create_autocmd("User", {
  pattern = "BetterNMappingExecuted",
  callback = function(args)
    -- args.data.key and args.data.mode are available here
  end
})

-- You will have to rebind `n` yourself
vim.keymap.set({ "n", "x" } "n", require("better-n").next, {expr = true, nowait = true})
vim.keymap.set({ "n", "x" }, "<s-n>", require("better-n").previous, {expr = true, nowait = true})

-- Create repeatable mappings using, which is useful when registering dynamic mappings to be repeatable:
local hunk_navigation = require("better-n").create(
  {
    next =  require("gitsigns").next_hunk,
    previous = require("gitsigns").prev_hunk
  }
)

vim.keymap.set({ "n", "x"}, "]h", hunk_navigation.next)
vim.keymap.set({ "n", "x"}, "[h", hunk_navigation.previous)
```

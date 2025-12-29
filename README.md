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
    -- These are default values, which can be omitted.
    -- By default, the following mappings are made repeatable using `n` and `<S-n>`:
    -- `f`, `F`, `t`, `T`, `*`, `#`, `/`, `?`
    disable_default_mappings = false,
    disable_cmdline_mappings = false,
  }
)

vim.nvim_create_autocmd("User", {
  pattern = "BetterNMappingExecuted",
  callback = function(args)
    -- args.data.repeatable_id and args.data.mode are available here
  end
})

-- You can create repeatable mappings in two ways:

-- 1. Use `create()` when you want to define your own custom keybindings:
local hunk_navigation = require("better-n").create(
  {
    next =  require("gitsigns").next_hunk,
    prev = require("gitsigns").prev_hunk
  }
)

vim.keymap.set({ "n", "x" }, "]h", hunk_navigation.next_key)
vim.keymap.set({ "n", "x" }, "[h", hunk_navigation.prev_key)

-- or

vim.keymap.set({ "n", "x" }, "]h", hunk_navigation.next, { expr = true })
vim.keymap.set({ "n", "x" }, "[h", hunk_navigation.prev, { expr = true })

-- 2. Use `listen()` when you want to make existing keybindings repeatable:
--    This monitors when specific keys are pressed and makes them repeatable with `n`
require("better-n").listen("5j", {
  next = "5gj",  -- Moving down by display line
  prev = "5gk"   -- Moving up by display line
})

-- Now when you press `gj`, you can repeat it with `n` and reverse with `N`
-- This is useful for commands that are already mapped by plugins or built-in Vim

--
```

## Repeatable buffer-local mappings
To make buffer-local mappings repeatable, you can wrap the mappings in a `FileType` autocommand.

```lua
 vim.api.nvim_create_autocmd(
  "FileType",
  {
    callback = function(args)
      local repeatable_square_brackets = require("better_n").create({ next = "]]", prev = "[[" })

      vim.keymap.set("n", "]]", repeatable_square_brackets.next_key, { buffer = args.buf })
      vim.keymap.set("n", "[[", repeatable_square_brackets.prev_key, { buffer = args.buf }))
  }
)
```

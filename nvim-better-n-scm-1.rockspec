rockspec_format = "3.0"
package = "nvim-better-n"
version = "scm-1"

dependencies = {
  "lua == 5.1",

  -- These are only needed for testing, but `test_dependencies` cannot
  -- be automatically installed based on the listing here, which makes
  -- that section all but useless.
  "nlua",
  "busted"
}

source = {
  url = "git://github.com/jonatan-branting/" .. package,
}

build = {
  type = "builtin",
}


rockspec_format = "3.0"
package = "nvim-better-n"
version = "scm-1"

dependencies = {
  "lua == 5.1",
}

test_dependencies = {
  "lua == 5.1",
  "busted"
}

source = {
  url = "git://github.com/jonatan-branting/" .. package,
}

build = {
  type = "builtin",
  copy_directories = {
    "plugin",
    "parser",
    "doc"
  },
}


local Repeatable = require("better-n.repeatable")

local M = {}

function M.forward()
  return _G.better_n_repeatable:forward()
end

function M.backward()
  return _G.better_n_repeatable:backward()
end

function M.create(opts)
  return _G.better_n_repeatable:create(opts)
end

function M.setup()
  if _G.better_n_repeatable then
    return
  end

  _G.better_n_repeatable = Repeatable:new():setup()
  _G.better_n_repeatable
    :register({ forward = "n", backward = "<s-n>", key = "/" })
    :register({ forward = "n", backward = "<s-n>", key = "?" })

  return M
end

return M

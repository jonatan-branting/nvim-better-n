-- Copy-pasted from nvim-cmp
local autocmd = {}

autocmd.events = {}

autocmd.subscribe = function(event, callback)
  autocmd.events[event] = autocmd.events[event] or {}
  table.insert(autocmd.events[event], callback)

  return function()
    for i, callback_ in ipairs(autocmd.events[event]) do
      if callback_ == callback then
        table.remove(autocmd.events[event], i)

        break
      end
    end
  end
end

autocmd.emit = function(event, ...)
  autocmd.events[event] = autocmd.events[event] or {}
  for _, callback in ipairs(autocmd.events[event]) do
    callback(...)
  end
end

return autocmd

local Enumerable = {}

function Enumerable:new(items)
  local instance = {
    items = items,
  }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

function Enumerable:append(item)
  table.insert(self.items, item)
end

function Enumerable:length()
  return #self.items
end

function Enumerable:any()
  return self:length() > 0
end

function Enumerable:to_table()
  return self.items
end

function Enumerable:each(func)
  for _, item in ipairs(self.items) do
    func(item)
  end
end

function Enumerable:map(func)
  local mapped = {}

  for _, item in ipairs(self.items) do
    local result, _ = func(item)
    table.insert(mapped, result)
  end

  return Enumerable:new(mapped)
end

function Enumerable:filter(func)
  local filtered = {}

  for _, item in ipairs(self.items) do
    if func(item) then
      table.insert(filtered, item)
    end
  end

  return Enumerable:new(filtered)
end

function Enumerable:select(func)
  return self:filter(func)
end

function Enumerable:reject(func)
  local filtered = {}

  for _, item in ipairs(self.items) do
    if not func(item) then
      table.insert(filtered, item)
    end
  end

  return Enumerable:new(filtered)
end

function Enumerable:reduce(func, initial)
  local result = initial

  for _, item in ipairs(self.items) do
    result = func(result, item)
  end

  return result
end

function Enumerable:find(func)
  for _, item in ipairs(self.items) do
    if func(item) then
      return item
    end
  end
end

function Enumerable:last()
  return self.items[#self.items]
end

function Enumerable:first()
  return self.items[1]
end

return Enumerable

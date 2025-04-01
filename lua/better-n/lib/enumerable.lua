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

function Enumerable:contains(item)
  return vim.tbl_contains(self.items, item)
end

function Enumerable:any(func)
  if not func then
    return self:length() > 0
  end

  return self:find(func) ~= nil
end

function Enumerable:to_table()
  return self.items
end

function Enumerable:each(func_or_func_name)
  local func = nil
  if type(func_or_func_name) == "string" then
    func = function(item, ...) return item[func_or_func_name](item, ...) end
  else
    func = func_or_func_name
  end

  for i, item in ipairs(self.items) do
    func(item, i)
  end
end

function Enumerable:map(func_or_func_name)
  local mapped = {}

  local func = nil
  if type(func_or_func_name) == "string" then
    func = function(item, ...) return item[func_or_func_name](item, ...) end
  else
    func = func_or_func_name
  end

  for i, item in ipairs(self.items) do
    local result, _ = func(item, i)

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

function Enumerable:table()
  return self.items
end

return Enumerable

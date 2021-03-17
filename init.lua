local assertType
assertType = function(Value, Type, Error)
  return assert(Type == type(Value), Error)
end
local assertTable
assertTable = function(Value, Error)
  return assertType(Value, 'table', Error)
end
local U = { }
U = {
  ab = function(Choice, A, B)
    return Choice and A or B
  end,
  isArray = function(List)
    if not ('table' == type(List)) then
      return false
    end
    return #List == #(function()
      local _accum_0 = { }
      local _len_0 = 1
      for i in pairs(List) do
        _accum_0[_len_0] = i
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()
  end,
  isObject = function(List)
    if not ('table' == type(List)) then
      return false
    end
    return not U.isArray(List)
  end,
  values = function(List)
    assertTable(List, "values: expected Table for arg#1, got " .. tostring(type(List)))
    if U.isArray(List) then
      return List
    end
    local _accum_0 = { }
    local _len_0 = 1
    for _, V in pairs(List) do
      _accum_0[_len_0] = V
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end,
  softCopy = function(List)
    local _tbl_0 = { }
    for I, V in pairs(List) do
      _tbl_0[I] = V
    end
    return _tbl_0
  end,
  hardCopy = function(List, Explored)
    if Explored == nil then
      Explored = { }
    end
    if 'table' == type(List) then
      if Explored[List] then
        return Explored[List]
      end
      Explored[List] = true
      local Result
      do
        local _tbl_0 = { }
        for I, V in pairs(List) do
          _tbl_0[U.hardCopy(I)] = U.hardCopy(V)
        end
        Result = _tbl_0
      end
      Explored[List] = Result
      return Result
    else
      return List
    end
  end,
  each = function(List, Fn)
    assertTable(List, "each: expected Table for arg#1, got " .. tostring(type(List)))
    assertType(Fn, 'function', "each: expected Function for arg#2, got " .. tostring(type(Fn)))
    for I, V in pairs(List) do
      Fn(V, I, List)
    end
    return List
  end,
  map = function(List, Fn)
    assertTable(List, "map: expected Table for arg#1, got " .. tostring(type(List)))
    assertType(Fn, 'function', "map: expected Function for arg#2, got " .. tostring(type(Fn)))
    local _tbl_0 = { }
    for I, V in pairs(List) do
      _tbl_0[I] = Fn(V, I, List)
    end
    return _tbl_0
  end,
  reduce = function(List, Fn, State)
    assertTable(List, "reduce: expected Table for arg#1, got " .. tostring(type(List)))
    assertType(Fn, 'function', "reduce: expected Function for arg#2, got " .. tostring(type(Fn)))
    for I, V in pairs(List) do
      if State == nil and I == 1 then
        State = V
      else
        State = Fn(State, V, I, List)
      end
    end
    return State
  end,
  find = function(List, Fn)
    assertTable(List, "find: expected Table for arg#1, got " .. tostring(type(List)))
    assertType(Fn, 'function', "find: expected Function for arg#2, got " .. tostring(type(Fn)))
    for I, V in pairs(List) do
      if Fn(V, I, List) then
        return V
      end
    end
  end,
  filter = function(List, Fn)
    assertTable(List, "filter: expected Table for arg#1, got " .. tostring(type(List)))
    assertType(Fn, 'function', "filter: expected Function for arg#2, got " .. tostring(type(Fn)))
    local _accum_0 = { }
    local _len_0 = 1
    for I, V in pairs(List) do
      if Fn(V, I, List) then
        _accum_0[_len_0] = V
        _len_0 = _len_0 + 1
      end
    end
    return _accum_0
  end,
  findWhere = function(List, Props)
    assertTable(List, "findWhere: expected Array for arg#1, got " .. tostring(type(List)))
    assertTable(Props, "findWhere: expected Object for arg#2, got " .. tostring(type(Props)))
    assert(U.isArray(List), "findWhere: expected Array for arg#1, got Object")
    assert(U.isObject(Props), "findWhere: expected Object for arg#2, got Array")
    return U.find(List, function(O)
      for I, V in pairs(Props) do
        if O[I] ~= V then
          return false
        end
      end
    end)
  end,
  where = function(List, Props)
    assertTable(List, "where: expected Array for arg#1, got " .. tostring(type(List)))
    assertTable(Props, "where: expected Object for arg#2, got " .. tostring(type(Props)))
    assert(U.isArray(List), "where: expected Array for arg#1, got Object")
    assert(U.isObject(Props), "where: expected Object for arg#2, got Array")
    return U.filter(List, function(O)
      for I, V in pairs(Props) do
        if O[I] ~= V then
          return false
        end
      end
    end)
  end,
  reject = function(List, Fn)
    assertTable(List, "reject: expected Table for arg#1, got " .. tostring(type(List)))
    assertType(Fn, 'function', "reject: expected Function for arg#2, got " .. tostring(type(Fn)))
    local _accum_0 = { }
    local _len_0 = 1
    for I, V in pairs(List) do
      if not Fn(V, I, List) then
        _accum_0[_len_0] = V
        _len_0 = _len_0 + 1
      end
    end
    return _accum_0
  end,
  every = function(List, Fn)
    assertTable(List, "every: expected Table for arg#1, got " .. tostring(type(List)))
    assertType(Fn, 'function', "every: expected Function for arg#2, got " .. tostring(type(Fn)))
    for I, V in pairs(List) do
      if not Fn(V, I, List) then
        return false
      end
    end
    return true
  end,
  some = function(List, Fn)
    assertTable(List, "some: expected Table for arg#1, got " .. tostring(type(List)))
    assertType(Fn, 'function', "some: expected Function for arg#2, got " .. tostring(type(Fn)))
    for I, V in pairs(List) do
      if Fn(V, I, List) then
        return true
      end
    end
    return false
  end,
  indexOf = function(List, Element)
    assertTable(List, "indexOf: expected Table for arg#1, got " .. tostring(type(List)))
    for I, V in pairs(List) do
      if V == Element then
        return I
      end
    end
  end,
  contains = function(List, Element)
    assertTable(List, "contains: expected Table for arg#1, got " .. tostring(type(List)))
    return nil ~= U.indexOf(List, Element)
  end,
  invoke = function(List, Method, ...)
    assertTable(List, "invoke: expected Table for arg#1, got " .. tostring(type(List)))
    local Args = {
      ...
    }
    return U.map(List, function(V)
      return V[Method](unpack(Args))
    end)
  end,
  pluck = function(List, Key)
    assertTable(List, "pluck: expected Table for arg#1, got " .. tostring(type(List)))
    return U.map(List, function(V, I)
      assertTable(V, "pluck: expected Table for element " .. tostring(I) .. ", got " .. tostring(type(V)))
      return V[Key]
    end)
  end,
  shuffle = function(List)
    assertTable(List, "shuffle: expected Array for arg#1, got " .. tostring(type(List)))
    List = U.softCopy(U.values(List))
    local Result = { }
    while #List > 1 do
      table.insert(Result, table.remove(List, math.random(1, #List)))
    end
    table.insert(Result, List[1])
    return Result
  end,
  sort = function(List, Fn)
    assertTable(List, "sort: expected Array for arg#1, got " .. tostring(type(List)))
    if Fn then
      assertType(Fn, 'function', "sort: expected Function for arg#2, got " .. tostring(type(Fn)))
    end
    List = U.softCopy(U.values(List))
    table.sort(List, Fn)
    return List
  end,
  reverse = function(List)
    assertTable(List, "reverse: expected Array for arg#1, got " .. tostring(type(List)))
    List = U.softCopy(U.values(List))
    local Result = { }
    while #List > 0 do
      table.insert(Result, table.remove(List))
    end
    return Result
  end,
  sample = function(List, N)
    if N == nil then
      N = 1
    end
    assertTable(List, "sample: expected Array for arg#1, got " .. tostring(type(List)))
    return U.first(U.shuffle(List), N)
  end,
  size = function(List)
    return #U.values(List)
  end,
  partition = function(List, Fn)
    assertTable(List, "partition: expected Table for arg#1, got " .. tostring(type(List)))
    assertType(Fn, 'function', "partition: expected Function for arg#2, got " .. tostring(type(Fn)))
    local Pass, Fail = { }, { }
    for I, V in pairs(List) do
      if Fn(V, I, List) then
        table.insert(Pass, V)
      else
        table.insert(Fail, V)
      end
    end
    return Pass, Fail
  end,
  compact = function(List)
    assertTable(List, "compact: expected Table for arg#1, got " .. tostring(type(List)))
    return U.filter(List, function(V)
      return V
    end)
  end,
  first = function(List, N)
    if N == nil then
      N = 1
    end
    local _accum_0 = { }
    local _len_0 = 1
    for I, V in pairs(List) do
      if I <= N then
        _accum_0[_len_0] = V
        _len_0 = _len_0 + 1
      end
    end
    return _accum_0
  end,
  join = function(List, Sep)
    if Sep == nil then
      Sep = ''
    end
    assertTable(List, "join: expected Table for arg#1, got " .. tostring(type(Object)))
    assertType(Sep, 'string', "join: expected string for arg#1, got " .. tostring(type(S)))
    return table.concat(List, Sep)
  end,
  defaults = function(Object, Properties)
    assertTable(Object, "defaults: expected Table for arg#1, got " .. tostring(type(Object)))
    assertTable(Object, "defaults: expected Table for arg#2, got " .. tostring(type(Properties)))
    for I in pairs(Properties) do
      if Object[I] == nil then
        Object[I] = Properties[I]
      end
    end
    return Object
  end,
  keys = function(Object)
    assertTable(Object, "keys: expected Table for arg#1, got " .. tostring(type(Object)))
    local _accum_0 = { }
    local _len_0 = 1
    for I in pairs(Object) do
      _accum_0[_len_0] = I
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end,
  plural = function(S, N)
    assertType(S, 'string', "plural: expected string for arg#1, got " .. tostring(type(S)))
    assertType(N, 'number', "plural: expected number for arg#2, got " .. tostring(type(N)))
    return S .. (N == 1 and '' or 's')
  end,
  capFirst = function(S)
    assertType(S, 'string', "capFirst: expected string for arg#1, got " .. tostring(type(S)))
    return S:sub(1, 1):upper() .. S:sub(2)
  end,
  stringify = function(A)
    local _exp_0 = type(A)
    if 'table' == _exp_0 then
      local s = ''
      local a, z
      if U.isArray(A) then
        s = U.join(U.map(A, U.stringify), ', ')
        a, z = '[', ']'
      else
        s = U.join(U.map(A, function(v, i)
          return U.stringify(i) .. ': ' .. U.stringify(v)
        end), ', ')
        a, z = '{', '}'
      end
      return a .. s .. z
    elseif 'string' == _exp_0 then
      return '"' .. A .. '\"'
    else
      return tostring(A)
    end
  end,
  rr = function(val, min, max, change)
    if change == nil then
      change = 0
    end
    return min + (val - min + change) % (max - min + 1)
  end,
  chain = function(Value)
    local Wrap = U(Value)
    local final = Value
    Wrap.value = function()
      return final
    end
    local m = getmetatable(Wrap)
    local old = m.__index
    return setmetatable(Wrap, {
      __index = function(self, FnName)
        do
          local fn = old(Wrap, FnName)
          if fn then
            return function(...)
              return U.chain(fn(...))
            end
          else
            return error('failed to find ' .. FnName)
          end
        end
      end
    })
  end,
  times = function(N, Fn)
    assertType(N, 'number', "times: expected number for arg#1, got " .. tostring(type(N)))
    assertType(Fn, 'function', "times: expected function for arg#2, got " .. tostring(type(Fn)))
    local _accum_0 = { }
    local _len_0 = 1
    for i = 1, N do
      _accum_0[_len_0] = Fn(i)
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end,
  result = function(Object, Key, Default)
    assertType(Object, 'table', "result: expected Table for arg#1, got " .. tostring(type(Object)))
    assert(Key ~= nil, 'result: expected key for arg#2, got nil')
    local X = Object[Key]
    if X ~= nil then
      return X
    end
    return Default
  end,
  curry = function(N, Fn, args)
    if args == nil then
      args = { }
    end
    assertType(N, 'number', "curry: expected number for arg#1, got " .. tostring(type(N)))
    assertType(Fn, 'function', "curry: expected function for arg#2, got " .. tostring(type(Fn)))
    return function(v)
      local a
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #args do
          local v = args[_index_0]
          _accum_0[_len_0] = v
          _len_0 = _len_0 + 1
        end
        a = _accum_0
      end
      local n = N - 1
      if n <= 0 then
        return Fn(unpack(a), v)
      else
        table.insert(a, v)
        return curry(n, Fn, a)
      end
    end
  end
}
if game then
  do
    U.Service = setmetatable({ }, {
      __index = function(self, K)
        return game:GetService(K)
      end
    })
    if U.Service.RunService:IsClient() then
      U.User = U.Service.Players.LocalPlayer
    end
  end
end
setmetatable(U, {
  __call = function(self, Value)
    do
      local Wrap = { }
      setmetatable(Wrap, {
        __index = function(self, FnName)
          do
            local Fn = rawget(Wrap, FnName)
            if Fn then
              return Fn
            end
          end
          do
            local Fn = U[FnName]
            if Fn then
              return function(...)
                return Fn(Value, ...)
              end
            else
              return error('failed to find ' .. FnName)
            end
          end
        end
      })
      return Wrap
    end
  end
})
return U

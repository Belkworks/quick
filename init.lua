local enforce
enforce = function(Name, Types, ...)
  if type(Types) ~= 'table' then
    Types = {
      Types
    }
  end
  local args = {
    ...
  }
  for i, v in pairs(args) do
    do
      local T = Types[i]
      if T then
        local _exp_0 = type(T)
        if 'string' == _exp_0 then
          local t = type(args[i])
          assert(t == T, Name .. ': expected ' .. T .. ' for arg#' .. i .. ', got ' .. t)
        elseif 'function' == _exp_0 then
          assert(T(args[i]), Name .. ': arg#' .. i .. ' failed typecheck!')
        else
          error('enforce: unexpected type!')
        end
      end
    end
  end
end
local U = { }
U = {
  enforce = enforce,
  noop = function() end,
  ab = function(Choice, A, B)
    return Choice and A or B
  end,
  identity = function(Value)
    return Value
  end,
  constant = function(Value)
    return function()
      return Value
    end
  end,
  iteratee = function(Value)
    local _exp_0 = type(Value)
    if 'nil' == _exp_0 then
      return U.identity
    elseif 'table' == _exp_0 then
      if U.isObject(Value) then
        return U.matcher(Value)
      end
    elseif 'function' == _exp_0 then
      return Value
    end
    return U.property(Value)
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
  isMatch = function(Object, Props)
    enforce('isMatch', {
      'table',
      'table'
    }, Object, Props)
    for I, V in pairs(Props) do
      if Object[I] ~= V then
        return false
      end
    end
    return true
  end,
  matcher = function(Props)
    return function(Object)
      return U.isMatch(Object, Props)
    end
  end,
  toPath = function(Path)
    if U.isArray(Path) then
      return Path
    else
      return {
        Path
      }
    end
  end,
  get = function(Object, Path)
    Path = U.toPath(Path)
    for _index_0 = 1, #Path do
      local v = Path[_index_0]
      Object = Object[v]
    end
    return Object
  end,
  property = function(Path)
    Path = U.toPath(Path)
    return function(Object)
      return U.get(Object, Path)
    end
  end,
  values = function(List)
    enforce('values', 'table', List)
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
  isEqual = function(A, B, Traversed)
    if Traversed == nil then
      Traversed = { }
    end
    local tA = type(A)
    local tB = type(B)
    if tA ~= tB then
      return false
    end
    local _exp_0 = tA
    if 'table' == _exp_0 then
      local checked = { }
      for I, V in pairs(A) do
        local _continue_0 = false
        repeat
          if Traversed[V] then
            _continue_0 = true
            break
          end
          Traversed[V] = true
          if not (U.isEqual(V, B[I], Traversed)) then
            return false
          end
          Traversed[V] = false
          checked[I] = true
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      for I, V in pairs(B) do
        local _continue_0 = false
        repeat
          if not (checked[I]) then
            if Traversed[V] then
              _continue_0 = true
              break
            end
            Traversed[V] = true
            if not (U.isEqual(V, A[I], Traversed)) then
              return false
            end
          end
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      return true
    else
      return A == B
    end
  end,
  each = function(List, Fn)
    enforce('each', 'table', List)
    Fn = U.iteratee(Fn)
    for I, V in pairs(List) do
      Fn(V, I, List)
    end
    return List
  end,
  map = function(List, Fn)
    enforce('map', {
      'table',
      'function'
    }, List, Fn)
    local _tbl_0 = { }
    for I, V in pairs(List) do
      _tbl_0[I] = Fn(V, I, List)
    end
    return _tbl_0
  end,
  reduce = function(List, Fn, State)
    enforce('reduce', {
      'table',
      'function'
    }, List, Fn)
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
    enforce('find', 'table', List)
    Fn = U.iteratee(Fn)
    for I, V in pairs(List) do
      if Fn(V, I, List) then
        return V
      end
    end
  end,
  findWhere = function(List, Props)
    enforce('findWhere', {
      'table',
      'table'
    }, List, Props)
    return U.find(List, function(O)
      return U.isMatch(O, Props)
    end)
  end,
  where = function(List, Props)
    enforce('findWhere', {
      'table',
      'table'
    }, List, Props)
    return U.filter(List, function(O)
      return U.isMatch(O, Props)
    end)
  end,
  filter = function(List, Fn)
    enforce('filter', 'table', List)
    Fn = U.iteratee(Fn)
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
  reject = function(List, Fn)
    enforce('reject', 'table', List)
    Fn = U.iteratee(Fn)
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
    enforce('every', 'table', List)
    Fn = U.iteratee(Fn)
    for I, V in pairs(List) do
      if not Fn(V, I, List) then
        return false
      end
    end
    return true
  end,
  some = function(List, Fn)
    enforce('some', 'table', List)
    Fn = U.iteratee(Fn)
    return nil ~= U.find(List, Fn)
  end,
  none = function(List, Fn)
    enforce('none', 'table', List)
    Fn = U.iteratee(Fn)
    return not U.some(List, Fn)
  end,
  indexOf = function(List, Element)
    enforce('indexOf', 'table', List)
    for I, V in pairs(List) do
      if V == Element then
        return I
      end
    end
  end,
  contains = function(List, Element)
    enforce('contains', 'table', List)
    return nil ~= U.indexOf(List, Element)
  end,
  invoke = function(List, Method, ...)
    enforce('invoke', {
      'table',
      'string'
    }, List, Method)
    local Args = {
      ...
    }
    return U.map(List, function(V)
      return V[Method](unpack(Args))
    end)
  end,
  pluck = function(List, Key)
    enforce('pluck', 'table', List)
    return U.map(List, function(V, I)
      return V[Key]
    end)
  end,
  nth = function(Array, N)
    if N >= 0 then
      return Array[N]
    else
      return Array[#Array + N + 1]
    end
  end,
  tail = function(Array)
    local _accum_0 = { }
    local _len_0 = 1
    for I, V in pairs(List) do
      if I ~= 1 then
        _accum_0[_len_0] = V
        _len_0 = _len_0 + 1
      end
    end
    return _accum_0
  end,
  flatten = function(A)
    local reducer
    reducer = function(S, V)
      if 'table' == type(V) then
        for _index_0 = 1, #V do
          local B = V[_index_0]
          table.insert(S, B)
        end
      else
        table.insert(S, V)
      end
      return S
    end
    return U.reduce(A, reducer, { })
  end,
  uniq = function(A)
    local reducer
    reducer = function(S, V)
      if not (U.contains(S, V)) then
        table.insert(S, V)
      end
      return S
    end
    return U.reduce(A, reducer, { })
  end,
  shuffle = function(List)
    enforce('shuffle', 'table', List)
    List = U.softCopy(U.values(List))
    local Result = { }
    while #List > 1 do
      table.insert(Result, table.remove(List, math.random(1, #List)))
    end
    table.insert(Result, List[1])
    return Result
  end,
  sort = function(List, Fn)
    enforce('sort', {
      'table',
      'function'
    }, List, Fn)
    List = U.softCopy(U.values(List))
    table.sort(List, Fn)
    return List
  end,
  reverse = function(List)
    enforce('reverse', 'table', List)
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
    enforce('sample', {
      'table',
      'number'
    }, List, N)
    return U.first(U.shuffle(List), N)
  end,
  size = function(List)
    return #U.values(List)
  end,
  partition = function(List, Fn)
    enforce('partition', {
      'table',
      'function'
    }, List, Fn)
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
    enforce('compact', 'table', List)
    return U.filter(List, function(V)
      return V
    end)
  end,
  first = function(List, N)
    if N == nil then
      N = 1
    end
    enforce('first', {
      'table',
      'number'
    }, List, N)
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
    enforce('join', {
      'table',
      'string'
    }, List, Sep)
    return table.concat(List, Sep)
  end,
  defaults = function(Object, Props)
    enforce('defaults', {
      'table',
      'table'
    }, Object, Props)
    for I in pairs(Props) do
      if Object[I] == nil then
        Object[I] = Props[I]
      end
    end
    return Object
  end,
  keys = function(Object)
    enforce('keys', 'table', Object)
    local _accum_0 = { }
    local _len_0 = 1
    for I in pairs(Object) do
      _accum_0[_len_0] = I
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end,
  plural = function(S, N)
    enforce('plural', {
      'string',
      'number'
    }, S, N)
    return S .. (N == 1 and '' or 's')
  end,
  capFirst = function(S)
    enforce('capFirst', 'string', S)
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
  phone = function(S)
    enforce('phone', 'string', S)
    local Substitutions = {
      S:upper(),
      'ABC',
      'DEF',
      'GHI',
      'JKL',
      'MNO',
      'PQRS',
      'TUV',
      'WXYZ'
    }
    return U.reduce(Substitutions, function(S, V, I)
      return S:gsub('[' .. V .. ']', tostring(I))
    end)
  end,
  rr = function(val, min, max, change)
    if change == nil then
      change = 0
    end
    enforce('rr', {
      'number',
      'number',
      'number',
      'number'
    }, val, min, max, change)
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
    enforce('times', {
      'number',
      'function'
    }, N, Fn)
    local _accum_0 = { }
    local _len_0 = 1
    for i = 1, N do
      _accum_0[_len_0] = Fn(i)
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end,
  result = function(Object, Key, Default)
    enforce('result', {
      'table',
      'string'
    }, Object, Key)
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
    enforce('curry', {
      'number',
      'function'
    }, N, Fn)
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
        return U.curry(n, Fn, a)
      end
    end
  end,
  uncurry = function(Fn)
    enforce('uncurry', 'function', Fn)
    return function(...)
      return U.reduce({
        ...
      }, (function(s, v)
        return s(v)
      end), Fn)
    end
  end,
  debounce = function(state)
    if state == nil then
      state = false
    end
    enforce('debounce', 'boolean', state)
    return function(set)
      if set == nil then
        set = true
      end
      if set == false then
        state = false
      elseif state then
        return true
      else
        state = true
      end
      return not state
    end
  end,
  rising = function(state)
    if state == nil then
      state = false
    end
    enforce('rising', 'boolean', state)
    local deb = U.debounce(state)
    return function(set)
      return not deb(set)
    end
  end,
  falling = function(state)
    if state == nil then
      state = true
    end
    enforce('falling', 'boolean', state)
    local deb = U.debounce(not state)
    return function(set)
      return not deb(not set)
    end
  end,
  stack = function(state)
    if state == nil then
      state = { }
    end
    enforce('stack', 'table', state)
    return {
      state = state,
      isEmpty = function()
        return #state == 0
      end,
      push = function(v)
        table.insert(state, v)
        return #v
      end,
      pop = function()
        return table.remove(state)
      end,
      peek = function()
        return state[#state]
      end
    }
  end,
  queue = function(state)
    if state == nil then
      state = { }
    end
    enforce('queue', 'table', state)
    return {
      state = state,
      isEmpty = function()
        return #state == 0
      end,
      push = function(v)
        table.insert(state, v)
        return #v
      end,
      next = function()
        return table.remove(state, 1)
      end,
      peek = function()
        return state[1]
      end
    }
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

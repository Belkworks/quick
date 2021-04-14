local U = { }
U = {
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
  throwing = function(Value)
    local Fn = U.iteratee(Value)
    return function(...)
      local S, R = pcall(Fn, ...)
      return S and R
    end
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
    return function(Object)
      return U.get(Object, Path)
    end
  end,
  values = function(List)
    local _accum_0 = { }
    local _len_0 = 1
    for _, V in pairs(List) do
      _accum_0[_len_0] = V
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end,
  clone = function(List)
    local _tbl_0 = { }
    for I, V in pairs(List) do
      _tbl_0[I] = V
    end
    return _tbl_0
  end,
  cloneDeep = function(List, Explored)
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
          _tbl_0[U.cloneDeep(I)] = U.cloneDeep(V)
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
    for I, V in pairs(List) do
      Fn(V, I, List)
    end
    return List
  end,
  map = function(List, Fn)
    Fn = U.iteratee(Fn)
    local _tbl_0 = { }
    for I, V in pairs(List) do
      _tbl_0[I] = Fn(V, I, List)
    end
    return _tbl_0
  end,
  reduce = function(List, Fn, State)
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
    Fn = U.iteratee(Fn)
    for I, V in pairs(List) do
      if Fn(V, I, List) then
        return V
      end
    end
  end,
  findIndex = function(List, Fn)
    Fn = U.iteratee(Fn)
    for I, V in pairs(List) do
      if Fn(V, I, List) then
        return I
      end
    end
  end,
  filter = function(List, Fn)
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
  findWhere = function(List, Props)
    return U.find(List, function(O)
      return U.isMatch(O, Props)
    end)
  end,
  where = function(List, Props)
    return U.filter(List, function(O)
      return U.isMatch(O, Props)
    end)
  end,
  reject = function(List, Fn)
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
    Fn = U.iteratee(Fn)
    for I, V in pairs(List) do
      if not Fn(V, I, List) then
        return false
      end
    end
    return true
  end,
  some = function(List, Fn)
    return nil ~= U.find(List, Fn)
  end,
  none = function(List, Fn)
    return nil == U.find(List, Fn)
  end,
  indexOf = function(List, Element)
    for I, V in pairs(List) do
      if V == Element then
        return I
      end
    end
  end,
  contains = function(List, Element)
    return nil ~= U.indexOf(List, Element)
  end,
  invoke = function(List, Method, ...)
    local Args = {
      ...
    }
    return U.map(List, function(V)
      return V[Method](unpack(Args))
    end)
  end,
  pluck = function(List, Key)
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
    for I, V in pairs(Array) do
      if I ~= 1 then
        _accum_0[_len_0] = V
        _len_0 = _len_0 + 1
      end
    end
    return _accum_0
  end,
  last = function(Array, N)
    if N == nil then
      N = 1
    end
    local Len = #Array
    local _accum_0 = { }
    local _len_0 = 1
    for I, V in pairs(Array) do
      if I > Len - N then
        _accum_0[_len_0] = V
        _len_0 = _len_0 + 1
      end
    end
    return _accum_0
  end,
  flatten = function(Array)
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
    return U.reduce(Array, reducer, { })
  end,
  uniq = function(Array)
    local reducer
    reducer = function(S, V)
      if not (U.contains(S, V)) then
        table.insert(S, V)
      end
      return S
    end
    return U.reduce(Array, reducer, { })
  end,
  difference = function(Array, ...)
    local flat = U.uniq(U.flatten({
      ...
    }))
    return U.reject(Array, function(V)
      return U.contains(flat, V)
    end)
  end,
  shuffle = function(Array)
    Array = U.clone(U.values(Array))
    local Result = { }
    while #Array > 1 do
      table.insert(Result, table.remove(Array, math.random(1, #Array)))
    end
    table.insert(Result, Array[1])
    return Result
  end,
  sort = function(Array, Fn)
    Array = U.clone(U.values(Array))
    table.sort(Array, Fn)
    return Array
  end,
  reverse = function(Array)
    Array = U.clone(U.values(Array))
    local Result = { }
    while #Array > 0 do
      table.insert(Result, table.remove(Array))
    end
    return Result
  end,
  sample = function(Array, N)
    if N == nil then
      N = 1
    end
    return U.first(U.shuffle(Array), N)
  end,
  size = function(Array)
    return #U.values(Array)
  end,
  partition = function(Array, Fn)
    Fn = U.iteratee(Fn)
    local Pass, Fail = { }, { }
    for I, V in pairs(Array) do
      if Fn(V, I, Array) then
        table.insert(Pass, V)
      else
        table.insert(Fail, V)
      end
    end
    return Pass, Fail
  end,
  compact = function(Array)
    return U.filter(Array, function(V)
      return V
    end)
  end,
  first = function(Array, N)
    if N == nil then
      N = 1
    end
    local _accum_0 = { }
    local _len_0 = 1
    for I, V in pairs(Array) do
      if I <= N then
        _accum_0[_len_0] = V
        _len_0 = _len_0 + 1
      end
    end
    return _accum_0
  end,
  join = function(Array, Sep)
    if Sep == nil then
      Sep = ''
    end
    return table.concat(Array, Sep)
  end,
  defaults = function(Object, Properties)
    for I, V in pairs(Properties) do
      if Object[I] == nil then
        Object[I] = V
      end
    end
    return Object
  end,
  merge = function(Object, Properties)
    for I, V in pairs(Properties) do
      Object[I] = V
    end
    return Object
  end,
  keys = function(Object)
    local _accum_0 = { }
    local _len_0 = 1
    for I in pairs(Object) do
      _accum_0[_len_0] = I
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end,
  plural = function(S, N)
    return S .. (N == 1 and '' or 's')
  end,
  capFirst = function(S)
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
    return min + (val + change - min) % (max + 1 - min)
  end,
  isEven = function(x)
    return x % 2 == 0
  end,
  isOdd = function(x)
    return x % 2 == 1
  end,
  add = function(x, y)
    return x + y
  end,
  sum = function(Array)
    return U.reduce(Array, U.add)
  end,
  multiply = function(x, y)
    return x * y
  end,
  product = function(Array)
    return U.reduce(Array, U.multiply)
  end,
  factorial = function(N)
    if N == nil then
      N = 1
    end
    return U.product(U.range(N))
  end,
  average = function(Array)
    return U.sum(Array) / #Array
  end,
  max = function(Array)
    return U.reduce(Array, U.ary(math.max, 2))
  end,
  min = function(Array)
    return U.reduce(Array, U.ary(math.min, 2))
  end,
  clamp = function(N, Min, Max)
    if Max then
      return math.min(Max, math.max(Min, N))
    else
      return math.min(Min, N)
    end
  end,
  chain = function(Value)
    local wrapped = { }
    local Wrapped = {
      chain = true,
      wrapped = wrapped,
      value = function()
        return _.reduce(wrapped, (function(s, v)
          return v.fn(s, unpack(v.args))
        end), Value)
      end
    }
    return setmetatable(Wrapped, {
      __index = function(self, K)
        local V = rawget(self, K)
        if V ~= nil then
          return V
        end
        local Fn = _[K]
        assert(Fn, 'invalid method in chain: ' .. tostring(K))
        return function(...)
          table.insert(wrapped, {
            fn = Fn,
            args = {
              ...
            }
          })
          return self
        end
      end
    })
  end,
  nowChain = function(Value)
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
    local _accum_0 = { }
    local _len_0 = 1
    for i = 1, N do
      _accum_0[_len_0] = Fn(i)
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end,
  result = function(Object, Key, Default)
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
    return function(...)
      return U.reduce({
        ...
      }, (function(s, v)
        return s(v)
      end), Fn)
    end
  end,
  tap = function(V, Fn)
    Fn(V)
    return V
  end,
  thru = function(V, Fn)
    return Fn(V)
  end,
  range = function(Max, Min, Step)
    if Min == nil then
      Min = 1
    end
    if Step == nil then
      Step = 1
    end
    local _accum_0 = { }
    local _len_0 = 1
    for I = Min, Max, Step do
      _accum_0[_len_0] = I
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end,
  nthArg = function(N)
    if N == nil then
      N = 1
    end
    return function(...)
      return U.nth({
        ...
      }, N)
    end
  end,
  ary = function(Fn, N)
    if N == nil then
      N = 1
    end
    return function(...)
      return Fn(unpack(U.first({
        ...
      }, N)))
    end
  end,
  unary = function(Fn)
    return function(V)
      return Fn(V)
    end
  end,
  after = function(N, Fn)
    if N == nil then
      N = 1
    end
    local count = 0
    return function(...)
      count = count + 1
      if count > N then
        return FN(...)
      end
    end
  end,
  before = function(N, Fn)
    if N == nil then
      N = 1
    end
    local Result = { }
    return function(...)
      if N <= 0 then
        return unpack(Result)
      end
      N = N - 1
      if N == 0 then
        Result = {
          Fn(...)
        }
        return unpack(Result)
      else
        return Fn(...)
      end
    end
  end,
  partial = function(Fn, ...)
    local args = {
      ...
    }
    return function(...)
      return Fn(unpack(args), ...)
    end
  end,
  partialRight = function(Fn, ...)
    local args = {
      ...
    }
    return function(...)
      return Fn(..., unpack(args))
    end
  end,
  flip = function(Fn)
    return function(...)
      return Fn(unpack(U.reverse({
        ...
      })))
    end
  end,
  negate = function(Fn)
    return function(...)
      return not Fn(...)
    end
  end,
  once = function(Fn)
    return U.before(1, Fn)
  end,
  overArgs = function(Fn, Transforms)
    return function(...)
      return Fn(unpack(U.map({
        ...
      }, function(V, I)
        return Transforms[I](V)
      end)))
    end
  end,
  combine = function(...)
    local Fns = {
      ...
    }
    return function(...)
      for _index_0 = 1, #Fns do
        local Fn = Fns[_index_0]
        Fn(...)
      end
    end
  end,
  lock = function(state)
    if state == nil then
      state = false
    end
    return {
      locked = function()
        return state == true
      end,
      lock = function()
        state = true
      end,
      unlock = function()
        state = false
      end
    }
  end,
  counter = function(state)
    if state == nil then
      state = 0
    end
    return {
      value = function()
        return state
      end,
      reset = function(to)
        if to == nil then
          to = 0
        end
        state = to
      end,
      count = function(amount)
        if amount == nil then
          amount = 1
        end
        state = state + amount
        return state
      end
    }
  end,
  debounce = function(state)
    if state == nil then
      state = false
    end
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
    local deb = U.debounce(state)
    return function(set)
      return not deb(set)
    end
  end,
  falling = function(state)
    if state == nil then
      state = true
    end
    local deb = U.debounce(not state)
    return function(set)
      return not deb(not set)
    end
  end,
  stack = function(state)
    if state == nil then
      state = { }
    end
    return {
      state = state,
      isEmpty = function()
        return #state == 0
      end,
      length = function()
        return #state
      end,
      push = function(v)
        table.insert(state, v)
        return #state
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
    return U.merge(U.stack(state), {
      pop = nil,
      next = function()
        return table.remove(state, 1)
      end,
      peek = function()
        return state[1]
      end
    })
  end
}
U.take = U.first
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
    U.waitFor = function(object, path, timeout)
      return U.reduce({
        object,
        unpack(path)
      }, function(o, n)
        return o:waitForChild(n, timeout)
      end)
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

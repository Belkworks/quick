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
  call = function(Fn, ...)
    return Fn(...)
  end,
  isArray = function(List)
    if (type(List)) ~= 'table' then
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
    if (type(List)) ~= 'table' then
      return false
    end
    return not U.isArray(List)
  end,
  isNil = function(Input)
    return Input == nil
  end,
  isMatch = function(Object, Props, Explored)
    if Explored == nil then
      Explored = { }
    end
    for I, V in pairs(Props) do
      if 'table' == type(V) then
        local O = Object[I]
        if not ('table' == type(O)) then
          return false
        end
        local R = Explored[V]
        if R ~= nil then
          return R
        end
        Explored[V] = true
        R = U.isMatch(O, V, Explored)
        if not (R) then
          return false
        end
        Explored[V] = R
      else
        if Object[I] ~= V then
          return false
        end
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
  get = function(Object, Path, Default)
    Path = U.toPath(Path)
    for _index_0 = 1, #Path do
      local v = Path[_index_0]
      local t = type(Object)
      if t == 'table' or t == 'userdata' then
        local val = Object[v]
        if val == nil then
          Object = Default
          break
        else
          Object = val
        end
      else
        Object = Default
        break
      end
    end
    return Object
  end,
  set = function(Object, Path, Value)
    local Ref = Object
    Path = U.toPath(Path)
    local _list_0 = U.initial(Path)
    for _index_0 = 1, #_list_0 do
      local k = _list_0[_index_0]
      Ref[k] = Ref[k] or { }
      Ref = Ref[k]
    end
    Ref[U.last(Path)] = Value
    return Object
  end,
  result = function(Object, Path, Default)
    local R = U.get(Object, Path)
    if R ~= nil then
      return R
    end
    local _exp_0 = type(Default)
    if 'function' == _exp_0 then
      return Default()
    else
      return Default
    end
  end,
  has = function(Object, Path)
    return nil ~= U.get(Object, Path)
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
  keysDeep = function(List, Keys, Prefix)
    if Keys == nil then
      Keys = { }
    end
    if Prefix == nil then
      Prefix = { }
    end
    local keys = U.keys(List)
    for _index_0 = 1, #keys do
      local k = keys[_index_0]
      local key = U.concat(Prefix, k)
      if 'table' == type(List[k]) then
        U.keysDeep(List[k], Keys, key)
      else
        table.insert(Keys, key)
      end
    end
    return Keys
  end,
  size = function(List)
    return #(function()
      local _accum_0 = { }
      local _len_0 = 1
      for k in pairs(List) do
        _accum_0[_len_0] = 1
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()
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
    for I, V in pairs(List) do
      if V == Element then
        return true
      end
    end
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
  pick = function(List, Keys)
    local _tbl_0 = { }
    for _index_0 = 1, #Keys do
      local V = Keys[_index_0]
      _tbl_0[V] = List[V]
    end
    return _tbl_0
  end,
  omit = function(List, Keys)
    local Other = U.difference(U.keys(List), Keys)
    local _tbl_0 = { }
    for _index_0 = 1, #Other do
      local V = Other[_index_0]
      _tbl_0[V] = List[V]
    end
    return _tbl_0
  end,
  countBy = function(List, Fn)
    Fn = U.iteratee(Fn)
    return U.reduce(List, (function(S, V, I)
      local K = Fn(V, I, List)
      if S[K] then
        S[K] = S[K] + 1
      else
        S[K] = 1
      end
      return S
    end), { })
  end,
  toPairs = function(List)
    local _accum_0 = { }
    local _len_0 = 1
    for K, V in pairs(List) do
      _accum_0[_len_0] = {
        K,
        V
      }
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end,
  fromPairs = function(Array)
    local _tbl_0 = { }
    for _index_0 = 1, #Array do
      local P = Array[_index_0]
      _tbl_0[P[1]] = P[2]
    end
    return _tbl_0
  end,
  count = function(Array)
    return #Array
  end,
  chunk = function(Array, N)
    if N == nil then
      N = 1
    end
    return U.reduce(Array, (function(S, V)
      do
        local Last = S[#S]
        if Last then
          if #Last < N then
            table.insert(Last, V)
            return S
          end
        end
      end
      table.insert(S, {
        V
      })
      return S
    end), { })
  end,
  concat = function(Array, ...)
    local Copy = U.clone(Array)
    local _list_0 = {
      ...
    }
    for _index_0 = 1, #_list_0 do
      local V = _list_0[_index_0]
      if U.isArray(V) then
        for _index_1 = 1, #V do
          local E = V[_index_1]
          table.insert(Copy, E)
        end
      else
        table.insert(Copy, V)
      end
    end
    return Copy
  end,
  nth = function(Array, N)
    if N >= 0 then
      return Array[N]
    else
      return Array[#Array + N + 1]
    end
  end,
  first = function(Array)
    return Array[1]
  end,
  initial = function(Array)
    local Len = #Array
    local _accum_0 = { }
    local _len_0 = 1
    for I, V in pairs(Array) do
      if I ~= Len then
        _accum_0[_len_0] = V
        _len_0 = _len_0 + 1
      end
    end
    return _accum_0
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
  take = function(Array, N)
    if N == nil then
      N = 1
    end
    local Result = { }
    for I, V in pairs(Array) do
      if I <= N then
        table.insert(Result, V)
      else
        break
      end
    end
    return Result
  end,
  drop = function(Array, N)
    if N == nil then
      N = 1
    end
    local _accum_0 = { }
    local _len_0 = 1
    for I, V in pairs(Array) do
      if I > N then
        _accum_0[_len_0] = V
        _len_0 = _len_0 + 1
      end
    end
    return _accum_0
  end,
  takeRight = function(Array, N)
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
  last = function(Array)
    return Array[#Array]
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
  sortBy = function(Array, Fn)
    Fn = U.iteratee(Fn)
    Array = U.clone(Array)
    local Metrics = U.fromPairs(U.map(U.uniq(Array), function(V, ...)
      return {
        V,
        Fn(V, ...)
      }
    end))
    table.sort(Array, function(A, B)
      return Metrics[A] < Metrics[B]
    end)
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
  fill = function(Array, Length, Value)
    if Value == nil then
      Value = 0
    end
    while #Array < Length do
      table.insert(Array, Value)
    end
    return Array
  end,
  sample = function(Array)
    return Array[math.random(1, #Array)]
  end,
  sampleSize = function(Array, N)
    if N == nil then
      N = 1
    end
    return U.take(U.shuffle(Array), N)
  end,
  takeSample = function(Array)
    local Len = #Array
    if Len == 0 then
      return 
    end
    return table.remove(Array, math.random(1, Len))
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
  join = function(Array, Sep)
    if Sep == nil then
      Sep = ''
    end
    return table.concat(Array, Sep)
  end,
  pop = function(Array)
    return table.remove(Array)
  end,
  push = function(Array, Value)
    table.insert(Array, Value)
    return #Array
  end,
  insert = function(Array, Value)
    table.insert(Array, Value)
    return Value
  end,
  shift = function(Array)
    return table.remove(Array, 1)
  end,
  unshift = function(Array, Value)
    return table.insert(Array, 1, Value)
  end,
  without = function(Array, ...)
    return U.difference(Array, {
      ...
    })
  end,
  pull = function(Array, ...)
    local ToRemove = U.uniq({
      ...
    })
    local I = 1
    while I <= #Array do
      for _index_0 = 1, #ToRemove do
        local T = ToRemove[_index_0]
        if Array[I] == T then
          table.remove(Array, I)
          I = I - 1
        end
      end
      I = I + 1
    end
    return Array
  end,
  remove = function(Array, Fn)
    return U.pull(Array, unpack(U.filter(Array, Fn)))
  end,
  defaults = function(Object, Properties)
    for I, V in pairs(Properties) do
      if Object[I] == nil then
        Object[I] = V
      end
    end
    return Object
  end,
  defaultsDeep = function(Object, Properties, Explored)
    if Explored == nil then
      Explored = { }
    end
    for I, V in pairs(Properties) do
      local T = Object[I]
      if T ~= nil then
        if (type(V)) == 'table' and (type(T)) == 'table' then
          do
            local E = Explored[T]
            if E then
              return E
            end
          end
          Explored[T] = '** circular **'
          U.defaultsDeep(T, V, Explored)
          Explored[T] = T
        end
      else
        Object[I] = U.cloneDeep(V)
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
  deconstruct = function(Template, Object)
    local _accum_0 = { }
    local _len_0 = 1
    local _list_0 = U.sort(U.keysDeep(Template))
    for _index_0 = 1, #_list_0 do
      local k = _list_0[_index_0]
      _accum_0[_len_0] = U.get(Object, k)
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end,
  reconstruct = function(Object, Template)
    local keys = U.sort(U.keysDeep(Template))
    do
      local result = { }
      for i, v in pairs(Object) do
        U.set(result, keys[i], v)
      end
      return result
    end
  end,
  plural = function(S, N)
    return S .. (N == 1 and '' or 's')
  end,
  lower = function(S)
    return S:lower()
  end,
  lowerFirst = function(S)
    return S:sub(1, 1):lower() .. S:sub(2)
  end,
  upper = function(S)
    return S:upper()
  end,
  upperFirst = function(S)
    return S:sub(1, 1):upper() .. S:sub(2)
  end,
  capitalize = function(S)
    return S:sub(1, 1):upper() .. S:sub(2):lower()
  end,
  startsWith = function(S, T)
    return T == S:sub(1, #T)
  end,
  endsWith = function(S, T)
    return T == S:sub(#S - #T + 1)
  end,
  ["repeat"] = function(S, N)
    if N == nil then
      N = 1
    end
    return S:rep(N)
  end,
  stringify = function(A)
    local _exp_0 = type(A)
    if 'table' == _exp_0 then
      local s = nil
      local a, z
      if U.isArray(A) then
        s = U.map(A, U.stringify)
        a, z = '[', ']'
      else
        s = U.values(U.map(A, function(v, i)
          return U.stringify(i) .. ': ' .. U.stringify(v)
        end))
        a, z = '{', '}'
      end
      return a .. U.join(s, ', ') .. z
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
  fromHex = function(val)
    return tonumber(val, 16)
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
  sumBy = function(Array, Fn)
    Fn = U.iteratee(Fn)
    return U.sum(U.map(Array, Fn))
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
  maxBy = function(Array, Fn)
    Fn = U.iteratee(Fn)
    local Metrics = U.map(Array, Fn)
    return Array[U.reduce(Metrics, (function(S, V, I)
      if V > Metrics[S] then
        return I
      else
        return S
      end
    end))]
  end,
  maxKeyBy = function(Collection, Fn)
    return U.maxBy((U.keys(Collection)), Fn)
  end,
  min = function(Array)
    return U.reduce(Array, U.ary(math.min, 2))
  end,
  minBy = function(Array, Fn)
    Fn = U.iteratee(Fn)
    local Metrics = U.map(Array, Fn)
    return Array[U.reduce(Metrics, (function(S, V, I)
      if V < Metrics[S] then
        return I
      else
        return S
      end
    end))]
  end,
  minKeyBy = function(Collection, Fn)
    return U.minBy((U.keys(Collection)), Fn)
  end,
  clamp = function(N, Min, Max)
    if Max then
      return math.min(Max, math.max(Min, N))
    else
      return math.min(Min, N)
    end
  end,
  chain = function(Value)
    local Wrapped = {
      chain = true,
      wrapped = { },
      target = Value,
      plant = function(self, target)
        self.target = target
      end,
      value = function(self)
        return U.reduce(self.wrapped, (function(s, v)
          return U[v.fn](s, unpack(v.args))
        end), self.target)
      end
    }
    return setmetatable(Wrapped, {
      __index = function(self, K)
        local V = rawget(self, K)
        if V ~= nil then
          return V
        end
        local Fn = U[K]
        assert(Fn, 'invalid method in chain: ' .. tostring(K))
        return function(...)
          local T
          do
            local _with_0 = U.clone(self)
            _with_0.wrapped = U.concat(_with_0.wrapped, {
              fn = K,
              args = {
                ...
              }
            })
            T = _with_0
          end
          return setmetatable(T, {
            __index = (getmetatable(Wrapped)).__index
          })
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
              return U.nowChain(fn(...))
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
      return Fn(unpack(U.take({
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
        return Fn(...)
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
  over = function(Fns)
    return function(...)
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #Fns do
        local Fn = Fns[_index_0]
        _accum_0[_len_0] = Fn(...)
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end
  end,
  overEvery = function(Fns)
    return function(...)
      local Args = {
        ...
      }
      return U.every(Fns, function(Fn)
        return Fn(unpack(Args))
      end)
    end
  end,
  overSome = function(Fns)
    return function(...)
      local Args = {
        ...
      }
      return U.some(Fns, function(Fn)
        return Fn(unpack(Args))
      end)
    end
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
  unbind = function(Fn)
    return function(self, ...)
      return Fn(...)
    end
  end,
  bind = function(Fn, Self)
    return function(...)
      return Fn(Self, ...)
    end
  end,
  namecall = function(Self, Method)
    return function(...)
      return Self[Method](Self, ...)
    end
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
  toggle = function(state)
    if state == nil then
      state = false
    end
    return {
      state = function()
        return state
      end,
      toggle = function()
        state = not state
        return state
      end,
      reset = function(to)
        if to == nil then
          to = false
        end
        state = to
      end
    }
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
  end,
  memoize = function(Getter, State)
    if State == nil then
      State = { }
    end
    local isFunction = 'function' == type(Getter)
    return setmetatable(State, {
      __index = function(T, K)
        local V = rawget(T, K)
        if V ~= nil then
          return V
        end
        if isFunction then
          V = Getter(K, T)
        else
          V = Getter
        end
        rawset(T, K, V)
        return V
      end
    })
  end,
  nonce = function(state)
    if state == nil then
      state = 0
    end
    return U.counter(state).count
  end,
  uniqueId = function(prefix)
    if prefix == nil then
      prefix = ''
    end
    return prefix .. U.uniqueCounter.count()
  end,
  mixin = function(Plugin)
    return U.merge(U, Plugin)
  end
}
U.head = U.first
U.car = U.first
U.cdr = U.tail
U.defaultdict = U.memoize
U.instantly = U.call
U.uniqueCounter = U.counter()
if game then
  do
    U.Service = U.defaultdict(function(K)
      return game:GetService(K)
    end)
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
    U.Instance = function(object, properties)
      if 'string' == type(object) then
        object = Instance.new(object)
      end
      if properties then
        U.merge(object, properties)
      end
      return object
    end
    U.hexColor = function(str)
      local values = {
        str:match('#?(%x%x)(%x%x)(%x%x)')
      }
      return Color3.fromRGB(unpack(U.chain(values).fill(3).map(U.fromHex):value()))
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

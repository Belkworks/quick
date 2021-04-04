-- quick.moon
-- SFZILabs 2020

enforce = (Name, Types, ...) ->
    if type(Types) != 'table'
        Types = { Types }

    args = {...}
    for i, v in pairs args
        if T = Types[i]
            switch type T
                when 'string' -- just compare type
                    t = type(args[i])
                    assert t == T, Name..': expected '..T..' for arg#'..i..', got '..t
                when 'function'
                    assert T(args[i]), Name..': arg#'..i..' failed typecheck!'
                else error 'enforce: unexpected type!'

U = {}
U = {
    -- Typechecking
    :enforce

    -- Utility
    noop: ->
    ab: (Choice, A, B) -> Choice and A or B
    identity: (Value) -> Value
    constant: (Value) -> -> Value
    iteratee: (Value) ->
        switch type Value
            when 'nil'
                return U.identity
            when 'table'
                if U.isObject Value
                    return U.matcher Value
            when 'function'
                return Value

        return U.property Value

    isArray: (List) ->
        return false unless 'table' == type List
        #List == #[i for i in pairs List]

    isObject: (List) ->
        return false unless 'table' == type List
        not U.isArray List

    isMatch: (Object, Props) -> -- Returns true if Object matches Props
        enforce 'isMatch', {'table', 'table'}, Object, Props
        return false for I, V in pairs Props when Object[I] ~= V
        true

    matcher: (Props) -> -- Returns a predicate that tests Object against Props
        (Object) -> U.isMatch Object, Props

    toPath: (Path) ->
        if U.isArray Path
            Path
        else { Path }

    get: (Object, Path) ->
        Path = U.toPath Path
        Object = Object[v] for v in *Path
        Object

    property: (Path) ->
        Path = U.toPath Path
        (Object) -> U.get Object, Path

    values: (List) ->
        enforce 'values', 'table', List
        return List if U.isArray List
        [V for _, V in pairs List]

    clone: (List) ->
        enforce 'clone', 'table', List
        {I, V for I, V in pairs List} -- Shallow copy of list

    cloneDeep: (List, Explored = {}) -> -- Recursive copy of list
        if 'table' == type List
            return Explored[List] if Explored[List]
            Explored[List] = true
            Result = {U.cloneDeep(I), U.cloneDeep(V) for I, V in pairs List}
            Explored[List] = Result
            Result
        else List

    isEqual: (A, B, Traversed = {}) ->
        tA = type A
        tB = type B
        return false if tA != tB
        switch tA
            when 'table'
                checked = {}
                for I, V in pairs A
                    continue if Traversed[V]
                    Traversed[V] = true
                    return false unless U.isEqual V, B[I], Traversed
                    Traversed[V] = false
                    checked[I] = true

                for I, V in pairs B
                    unless checked[I]
                        continue if Traversed[V]
                        Traversed[V] = true
                        return false unless U.isEqual V, A[I], Traversed

                true
            else A == B

    -- Collections
    each: (List, Fn) -> -- Runs Fn on each element
        enforce 'each', 'table', List
        Fn = U.iteratee Fn -- don't need to typecheck Fn
        Fn V, I, List for I, V in pairs List
        List
    
    map: (List, Fn) -> -- Returns list of Fn (element)
        enforce 'map', {'table', 'function'}, List, Fn
        {I, Fn V, I, List for I, V in pairs List}

    reduce: (List, Fn, State) -> -- Reduces list to single value, state defaults to first value
        enforce 'reduce', {'table', 'function'}, List, Fn
        for I, V in pairs List
            State = if State == nil and I == 1 -- skip the first
                V -- default to first value
            else Fn State, V, I, List

        State

    find: (List, Fn) -> -- Returns first value that passes Fn
        enforce 'find', 'table', List
        Fn = U.iteratee Fn
        return V for I, V in pairs List when Fn V, I, List

    findWhere: (List, Props) -> -- Returns first object matching properties
        enforce 'findWhere', {'table', 'table'}, List, Props
        U.find List, (O) -> U.isMatch O, Props

    where: (List, Props) -> -- Returns all objects matching properties
        enforce 'findWhere', {'table', 'table'}, List, Props
        U.filter List, (O) -> U.isMatch O, Props

    filter: (List, Fn) -> -- Returns each value that passes Fn
        enforce 'filter', 'table', List
        Fn = U.iteratee Fn
        [V for I, V in pairs List when Fn V, I, List]

    reject: (List, Fn) -> -- Opposite of filter, returns failed Fn
        enforce 'reject', 'table', List
        Fn = U.iteratee Fn
        [V for I, V in pairs List when not Fn V, I, List]

    every: (List, Fn) -> -- Returns true if every element passes Fn
        enforce 'every', 'table', List
        Fn = U.iteratee Fn
        return false for I, V in pairs List when not Fn V, I, List
        true

    some: (List, Fn) -> -- Returns true if some elements pass Fn
        enforce 'some', 'table', List
        Fn = U.iteratee Fn
        nil != U.find List, Fn

    none: (List, Fn) -> -- Returns true if no elements pass Fn
        enforce 'none', 'table', List
        Fn = U.iteratee Fn
        return not U.some List, Fn

    indexOf: (List, Element) -> -- Returns index of Element in List
        enforce 'indexOf', 'table', List
        return I for I, V in pairs List when V == Element

    contains: (List, Element) -> -- Returns true if List has Element
        enforce 'contains', 'table', List
        nil ~= U.indexOf List, Element

    invoke: (List, Method, ...) -> -- Returns list of value[method] ...
        enforce 'invoke', {'table', 'string'}, List, Method
        Args = {...}
        U.map List, (V) -> V[Method] unpack Args

    pluck: (List, Key) -> -- Returns list of each value[key]
        enforce 'pluck', 'table', List
        U.map List, (V, I) -> V[Key]

    -- Arrays
    nth: (Array, N) ->
        enforce 'nth', {'table', 'number'}, Array, N
        if N >= 0
            Array[N]
        else Array[#Array + N + 1]

    tail: (Array) ->
        enforce 'tail', 'table', Array
        [V for I, V in pairs List when I != 1]

    flatten: (A) ->
        enforce 'flatten', 'table', A
        reducer = (S, V) ->
            if 'table' == type V
                table.insert S, B for B in *V
            else table.insert S, V
            S
        U.reduce A, reducer, {}

    uniq: (A) ->
        enforce 'uniq', 'table', A
        reducer = (S, V) ->
            table.insert S, V unless U.contains S, V
            S
        U.reduce A, reducer, {}

    difference: (A, ...) ->
        enforce 'difference', 'table', A
        flat = U.uniq U.flatten {...}
        U.reject A, (V) -> U.contains flat, V

    shuffle: (List) -> -- Returns shuffled copy
        enforce 'shuffle', 'table', List
        List = U.clone U.values List
        Result = {}
        while #List > 1
            table.insert Result, table.remove List, math.random 1, #List
        table.insert Result, List[1]
        Result

    sort: (List, Fn) -> -- Returns a sorted copy
        enforce 'sort', {'table', 'function'}, List, Fn
        List = U.clone U.values List
        table.sort List, Fn

        List

    reverse: (List) -> -- Returns a backwards copy
        enforce 'reverse', 'table', List
        List = U.clone U.values List
        
        Result = {}
        while #List > 0
            table.insert Result, table.remove List
        
        Result

    sample: (List, N = 1) -> -- Returns random sample
        enforce 'sample', {'table', 'number'}, List, N
        U.first U.shuffle(List), N

    size: (List) -> #U.values List -- Returns count of array/object

    partition: (List, Fn) -> -- Returns list of passing values and list of failing values
        enforce 'partition', {'table', 'function'}, List, Fn
        Pass, Fail = {}, {}
        for I, V in pairs List
            if Fn V, I, List
                table.insert Pass, V
            else table.insert Fail, V

        Pass, Fail

    compact: (List) -> -- Filter out falsy values
        enforce 'compact', 'table', List
        U.filter List, (V) -> V

    first: (List, N = 1) -> -- Get first N of List 
        enforce 'first', {'table', 'number'}, List, N
        [V for I, V in pairs List when I <= N]

    join: (List, Sep = '') -> -- Concat a table
        enforce 'join', {'table', 'string'}, List, Sep
        table.concat List, Sep

    -- Objects
    defaults: (Object, Props) ->
        enforce 'defaults', {'table', 'table'}, Object, Props
        Object[I] = Props[I] for I in pairs Props when Object[I] == nil
        Object

    keys: (Object) ->
        enforce 'keys', 'table', Object
        [I for I in pairs Object]

    -- Strings
    plural: (S, N) ->
        enforce 'plural', {'string', 'number'}, S, N
        S .. (N == 1 and '' or 's')

    capFirst: (S) ->
        enforce 'capFirst', 'string', S
        S\sub(1,1)\upper! .. S\sub 2

    stringify: (A) ->
        switch type A
            when 'table'
                s = ''
                a, z = if U.isArray A
                    s = U.join U.map(A, U.stringify), ', '
                    '[', ']'
                else

                    s = U.join U.map(A, (v, i) -> U.stringify(i).. ': '..U.stringify v), ', '
                    '{', '}'
                
                a .. s .. z
            when 'string'
                '"' .. A .. '\"'
            else tostring A
    
    phone: (S) ->
        enforce 'phone', 'string', S
        Substitutions = {
            S\upper!, 'ABC', 'DEF',
            'GHI', 'JKL', 'MNO',
            'PQRS', 'TUV','WXYZ'
        }
        U.reduce Substitutions, (S, V, I) -> S\gsub '['..V..']', tostring I

    -- Math
    rr: (val, min, max, change = 0) ->
        enforce 'rr', {'number', 'number', 'number', 'number'}, val, min, max, change
        min + (val-min+change)%(max-min+1) -- round robin

    max: (List) ->
        U.reduce List, U.ary math.max, 2

    min: (List) ->
        U.reduce List, U.ary math.min, 2

    clamp: (N, Min, Max) ->
        if Max
            math.min Max, math.max Min, N
        else math.min Min, N

    -- Helper
    chain: (Value) ->
        Wrap = U Value
        final = Value
        Wrap.value = -> final

        m = getmetatable Wrap
        old = m.__index
        setmetatable Wrap, __index: (FnName) =>
            if fn = old Wrap, FnName
                (...) -> return U.chain fn ...
            else error 'failed to find ' .. FnName

    times: (N, Fn) ->
        enforce 'times', {'number', 'function'}, N, Fn
        [Fn i for i = 1, N]

    result: (Object, Key, Default) ->
        enforce 'result', {'table', 'string'}, Object, Key

        X = Object[Key]
        return X if X != nil

        Default

    curry: (N, Fn, args = {}) -> -- curry Fn with N args
        enforce 'curry', {'number', 'function'}, N, Fn
        (v) ->
            a = [v for v in *args]
            n = N - 1
            if n <= 0
                Fn unpack(a), v
            else
                table.insert a, v
                U.curry n, Fn, a

    uncurry: (Fn) -> -- return uncurry runner
        enforce 'uncurry', 'function', Fn
        (...) -> U.reduce {...}, ((s, v) -> s v), Fn

    -- debounce(state = false) -> (set = true) -> bool
    debounce: (state = false) ->
        enforce 'debounce', 'boolean', state

        (...) -> U.reduce {...}, ((s, v) -> s v), Fn

    tap: (V, Fn) ->
        Fn V
        V

    thru: (V, Fn) ->
        Fn V

    range: (Max, Min = 1, Step = 1) ->
        [I for I = Min, Max, Step]

    nthArg: (N = 1) ->
        (...) -> U.nth {...}, N

    ary: (Fn, N = 1) -> -- (...) -> Fn ...[1..N]
        (...) -> Fn unpack U.first {...}, N

    unary: (Fn) ->
        (V) -> Fn V

    after: (N = 1, Fn) ->
        count = 0
        (...) ->
            count += 1
            if count >= N
                FN ...

    before: (N = 1, Fn) ->
        Result = {}
        (...) ->
            return unpack Result if N <= 0
            N -= 1
            if N == 0
                Result = { Fn ... }
                unpack Result
            else Fn ...

    partial: (Fn, ...) ->
        args = {...}
        (...) -> Fn unpack(args), ...

    partialRight: (Fn, ...) ->
        args = {...}
        (...) -> Fn ..., unpack args

    flip: (Fn) ->
        (...) -> Fn unpack U.reverse {...}

    negate: (Fn) ->
        (...) -> not Fn ...

    once: (Fn) -> U.before 1, Fn

    overArgs: (Fn, Transforms) -> -- Fn a, b -> Fn Transforms[1]a, Transforms[2]b
        (...) -> Fn unpack U.map {...}, (V, I) -> Transforms[I] V

    combine: (...) ->
        Fns = {...}
        (...) -> Fn ... for Fn in *Fns

    -- debounce(state = false) -> (set = true) -> bool
    debounce: (state = false) ->
        (set = true) ->
            if set == false
                state = false
            elseif state
                return true
            else state = true

            not state

    -- rising(state = false) -> (set) -> bool
    rising: (state = false) ->
        enforce 'rising', 'boolean', state

        deb = U.debounce state
        (set) -> not deb set

    -- rising(state = true) -> (set) -> bool
    falling: (state = true) ->
        enforce 'falling', 'boolean', state

        deb = U.debounce not state
        (set) -> not deb not set

    -- data structures
    stack: (state = {}) ->
        {
            :state
            isEmpty: -> #state == 0
            length: -> #state
            push: (v) ->
                table.insert state, v
                #state
            pop: -> table.remove state
            peek: -> state[#state]
        }

    queue: (state = {}) ->
        {
            :state
            isEmpty: -> #state == 0
            length: -> #state
            push: (v) ->
                table.insert state, v
                #state
            next: -> table.remove state, 1
            peek: -> state[1]
        }

}

if game
    with U
        .Service = setmetatable {}, __index: (K) => game\GetService K
        if .Service.RunService\IsClient!
            .User = .Service.Players.LocalPlayer

        .waitFor = (object, path, timeout) ->
            U.reduce {object, unpack path}, (o, n) -> o\waitForChild n, timeout

setmetatable U, __call: (Value) =>
    with Wrap = {}
        setmetatable Wrap, __index: (FnName) =>
            if Fn = rawget Wrap, FnName
                return Fn 
            
            if Fn = U[FnName]
                return (...) -> Fn Value, ...
            else error 'failed to find ' .. FnName

U

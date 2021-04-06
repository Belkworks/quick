-- quick.moon
-- SFZILabs 2020

U = {}
U = {
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
        return List if U.isArray List
        [V for _, V in pairs List]

    clone: (List) -> {I, V for I, V in pairs List} -- Shallow copy of list

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
        Fn V, I, List for I, V in pairs List
        List
    
    map: (List, Fn) -> -- Returns list of Fn (element)
        Fn = U.iteratee Fn
        {I, Fn V, I, List for I, V in pairs List}

    reduce: (List, Fn, State) -> -- Reduces list to single value, state defaults to first value
        for I, V in pairs List
            State = if State == nil and I == 1 -- skip the first
                V -- default to first value
            else Fn State, V, I, List

        State

    find: (List, Fn) -> -- Returns first value that passes Fn
        Fn = U.iteratee Fn
        return V for I, V in pairs List when Fn V, I, List

    findIndex: (List, Fn) -> -- Returns first index that passes Fn
        Fn = U.iteratee Fn
        return I for I, V in pairs List when Fn V, I, List

    filter: (List, Fn) -> -- Returns each value that passes Fn
        Fn = U.iteratee Fn
        [V for I, V in pairs List when Fn V, I, List]

    findWhere: (List, Props) -> -- Returns first object matching properties
        U.find List, (O) -> U.isMatch O, Props

    where: (List, Props) -> -- Returns all objects matching properties
        U.filter List, (O) -> U.isMatch O, Props

    reject: (List, Fn) -> -- Opposite of filter, returns failed Fn
        Fn = U.iteratee Fn
        [V for I, V in pairs List when not Fn V, I, List]

    every: (List, Fn) -> -- Returns true if every element passes Fn
        Fn = U.iteratee Fn
        return false for I, V in pairs List when not Fn V, I, List
        true

    some: (List, Fn) -> -- Returns true if some elements pass Fn
        nil != U.find List, Fn

    none: (List, Fn) -> -- Returns true if no elements pass Fn
        return not U.some List, Fn

    indexOf: (List, Element) -> -- Returns index of Element in List
        return I for I, V in pairs List when V == Element

    contains: (List, Element) -> -- Returns true if List has Element
        nil ~= U.indexOf List, Element

    invoke: (List, Method, ...) -> -- Returns list of value[method] ...
        Args = {...}
        U.map List, (V) -> V[Method] unpack Args

    pluck: (List, Key) -> -- Returns list of each value[key]
        U.map List, (V, I) -> V[Key]

    -- Arrays
    nth: (Array, N) ->
        if N >= 0
            Array[N]
        else Array[#Array + N + 1]

    tail: (Array) ->
        [V for I, V in pairs Array when I != 1]

    last: (Array, N = 1) ->
        Len = #Array
        [V for I, V in pairs Array when I > Len - N]

    flatten: (Array) ->
        reducer = (S, V) ->
            if 'table' == type V
                table.insert S, B for B in *V
            else table.insert S, V
            S
        U.reduce Array, reducer, {}

    uniq: (Array) ->
        reducer = (S, V) ->
            table.insert S, V unless U.contains S, V
            S
        U.reduce Array, reducer, {}

    difference: (Array, ...) ->
        flat = U.uniq U.flatten {...}
        U.reject Array, (V) -> U.contains flat, V

    shuffle: (Array) -> -- Returns shuffled copy
        Array = U.clone U.values Array
        Result = {}
        while #Array > 1
            table.insert Result, table.remove Array, math.random 1, #Array
        table.insert Result, Array[1]
        Result

    sort: (Array, Fn) -> -- Returns a sorted copy
        Array = U.clone U.values Array
        table.sort Array, Fn

        Array

    reverse: (Array) -> -- Returns a backwards copy
        Array = U.clone U.values Array
        
        Result = {}
        while #Array > 0
            table.insert Result, table.remove Array
        
        Result

    sample: (Array, N = 1) -> -- Returns random sample
        U.first U.shuffle(Array), N

    size: (Array) -> #U.values Array -- Returns count of array/object

    partition: (Array, Fn) -> -- Returns list of passing values and list of failing values
        Fn = U.iteratee Fn
        Pass, Fail = {}, {}
        for I, V in pairs Array
            if Fn V, I, Array
                table.insert Pass, V
            else table.insert Fail, V

        Pass, Fail

    compact: (Array) -> -- Filter out falsy values
        U.filter Array, (V) -> V

    first: (Array, N = 1) -> -- Get first N of List 
        [V for I, V in pairs Array when I <= N]

    join: (Array, Sep = '') -> -- Concat a table
        table.concat Array, Sep

    -- Objects
    defaults: (Object, Properties) ->
        Object[I] = V for I, V in pairs Properties when Object[I] == nil
        Object

    merge: (Object, Properties) ->
        Object[I] = V for I, V in pairs Properties
        Object

    keys: (Object) ->
        [I for I in pairs Object]

    -- Strings
    plural: (S, N) ->
        S .. (N == 1 and '' or 's')

    capFirst: (S) ->
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
        Substitutions = {
            S\upper!, 'ABC', 'DEF',
            'GHI', 'JKL', 'MNO',
            'PQRS', 'TUV','WXYZ'
        }
        U.reduce Substitutions, (S, V, I) -> S\gsub '['..V..']', tostring I

    -- Math
    rr: (val, min, max, change = 0) -> min + (val-min+change)%(max-min+1) -- round robin

    add: (x, y) -> x + y

    sum: (Array) ->
        U.reduce Array, U.add

    average: (Array) ->
        U.sum(Array)/#Array

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
        [Fn i for i = 1, N]

    result: (Object, Key, Default) ->
        X = Object[Key]
        return X if X != nil

        Default

    curry: (N, Fn, args = {}) -> -- curry Fn with N args
        (v) ->
            a = [v for v in *args]
            n = N - 1
            if n <= 0
                Fn unpack(a), v
            else
                table.insert a, v
                U.curry n, Fn, a

    uncurry: (Fn) -> -- return uncurry runner
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
        deb = U.debounce state
        (set) -> not deb set

    -- rising(state = true) -> (set) -> bool
    falling: (state = true) ->
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
        U.merge U.stack(state),
            pop: nil
            next: -> table.remove state, 1
            peek: -> state[1]

}

-- Aliases
U.take = U.first

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

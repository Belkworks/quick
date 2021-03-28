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
        [V for I, V in pairs List when I != 1]

    flatten: (A) ->
        reducer = (S, V) ->
            if 'table' == type V
                table.insert S, B for B in *V
            else table.insert S, V
            S
        U.reduce A, reducer, {}

    uniq: (A) ->
        reducer = (S, V) ->
            table.insert S, V unless U.contains S, V
            S
        U.reduce A, reducer, {}

    difference: (A, ...) ->
        flat = U.uniq U.flatten {...}
        U.reject A, (V) -> U.contains flat, V

    shuffle: (List) -> -- Returns shuffled copy
        List = U.clone U.values List
        Result = {}
        while #List > 1
            table.insert Result, table.remove List, math.random 1, #List
        table.insert Result, List[1]
        Result

    sort: (List, Fn) -> -- Returns a sorted copy
        List = U.clone U.values List
        table.sort List, Fn

        List

    reverse: (List) -> -- Returns a backwards copy
        List = U.clone U.values List
        
        Result = {}
        while #List > 0
            table.insert Result, table.remove List
        
        Result

    sample: (List, N = 1) -> -- Returns random sample
        U.first U.shuffle(List), N

    size: (List) -> #U.values List -- Returns count of array/object

    partition: (List, Fn) -> -- Returns list of passing values and list of failing values
        Fn = U.iteratee Fn
        Pass, Fail = {}, {}
        for I, V in pairs List
            if Fn V, I, List
                table.insert Pass, V
            else table.insert Fail, V

        Pass, Fail

    compact: (List) -> -- Filter out falsy values
        U.filter List, (V) -> V

    first: (List, N = 1) -> -- Get first N of List 
        [V for I, V in pairs List when I <= N]

    join: (List, Sep = '') -> -- Concat a table
        table.concat List, Sep

    -- Objects
    defaults: (Object, Properties) ->
        Object[I] = Properties[I] for I in pairs Properties when Object[I] == nil
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

    stack: (state = {}) ->
        {
            :state
            isEmpty: -> #state == 0
            push: (v) ->
                table.insert state, v
                #v
            pop: -> table.remove state
            peek: -> state[#state]
        }

    queue: (state = {}) ->
        {
            :state
            isEmpty: -> #state == 0
            push: (v) ->
                table.insert state, v
                #v
            next: -> table.remove state, 1
            peek: -> state[1]
        }

}

if game
    with U
        .Service = setmetatable {}, __index: (K) => game\GetService K
        if .Service.RunService\IsClient!
            .User = .Service.Players.LocalPlayer

setmetatable U, __call: (Value) =>
    with Wrap = {}
        setmetatable Wrap, __index: (FnName) =>
            if Fn = rawget Wrap, FnName
                return Fn 
            
            if Fn = U[FnName]
                return (...) -> Fn Value, ...
            else error 'failed to find ' .. FnName

U

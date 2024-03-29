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

    throwing: (Value) ->
        Fn = U.iteratee Value
        (...) ->
            S, R = pcall Fn, ...
            S and R

    call: (Fn, ...) -> Fn ...

    isArray: (List) ->
        return false if (type List) != 'table' 
        #List == #[i for i in pairs List]

    isObject: (List) ->
        return false if (type List) != 'table' 
        not U.isArray List

    isNil: (Input) ->
        Input == nil

    isMatch: (Object, Props, Explored = {}) -> -- Returns true if Object matches Props
        for I, V in pairs Props -- TODO: cleanup
            if 'table' == type V
                O = Object[I]
                return false unless 'table' == type O
                R = Explored[V]
                return R if R != nil
                Explored[V] = true
                R = U.isMatch O, V, Explored
                return false unless R
                Explored[V] = R
            else return false if Object[I] != V
        true

    matcher: (Props) -> -- Returns a predicate that tests Object against Props
        (Object) -> U.isMatch Object, Props

    toPath: (Path) ->
        if U.isArray Path
            Path
        else { Path }

    get: (Object, Path, Default) ->
        Path = U.toPath Path
        for v in *Path
            t = type Object
            if t == 'table' or t == 'userdata'
                val = Object[v]
                if val == nil
                    Object = Default
                    break
                else Object = val
            else
                Object = Default
                break
        
        Object

    set: (Object, Path, Value) ->
        Ref = Object
        Path = U.toPath Path
        for k in *U.initial Path
            Ref[k] or= {}
            Ref = Ref[k]

        Ref[U.last Path] = Value
        Object

    result: (Object, Path, Default) ->
        R = U.get Object, Path
        return R if R != nil
        switch type Default
            when 'function'
                Default!
            else Default

    has: (Object, Path) ->
        nil != U.get Object, Path

    property: (Path) ->
        (Object) -> U.get Object, Path

    values: (List) ->
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
    keysDeep: (List, Keys = {}, Prefix = {}) ->
        keys = U.keys List
        for k in *keys
            key = U.concat Prefix, k
            if 'table' == type List[k]
                U.keysDeep List[k], Keys, key
            else table.insert Keys, key

        Keys

    size: (List) -> -- Returns size of list
        #[1 for k in pairs List] 

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
        nil == U.find List, Fn

    indexOf: (List, Element) -> -- Returns index of Element in List
        return I for I, V in pairs List when V == Element

    contains: (List, Element) -> -- Returns true if List has Element
        return true for I, V in pairs List when V == Element

    invoke: (List, Method, ...) -> -- Returns list of value[method] ...
        Args = {...}
        U.map List, (V) -> V[Method] unpack Args

    pluck: (List, Key) -> -- Returns list of each value[key]
        U.map List, (V, I) -> V[Key]

    pick: (List, Keys) -> -- Returns {list[key[0]], list[key[1]], ...}
        {V, List[V] for V in *Keys}

    omit: (List, Keys) -> -- Returns list without any keys in Keys
        Other = U.difference U.keys(List), Keys
        {V, List[V] for V in *Other}

    countBy: (List, Fn) ->
        Fn = U.iteratee Fn
        U.reduce List, ((S, V, I) ->
            K = Fn V, I, List
            S[K] = if S[K]
                S[K] + 1
            else 1
            S
        ), {}

    toPairs: (List) ->
        [{K, V} for K, V in pairs List]

    -- Arrays
    fromPairs: (Array) ->
        {P[1], P[2] for P in *Array}

    count: (Array) -> #Array

    chunk: (Array, N = 1) ->
        U.reduce Array, ((S, V) ->
            if Last = S[#S]
                if #Last < N
                    table.insert Last, V
                    return S

            table.insert S, {V}
            S
        ), {}

    concat: (Array, ...) ->
        Copy = U.clone Array
        for V in *{...}
            if U.isArray V
                table.insert Copy, E for E in *V
            else table.insert Copy, V
        Copy

    nth: (Array, N) ->
        if N >= 0
            Array[N]
        else Array[#Array + N + 1]

    first: (Array) ->
        Array[1]

    initial: (Array) ->
        Len = #Array
        [V for I, V in pairs Array when I != Len]

    tail: (Array) ->
        [V for I, V in pairs Array when I != 1]

    take: (Array, N = 1) -> -- Get first N of List 
        Result = {}
        for I, V in pairs Array
            if I <= N
                table.insert Result, V
            else break
        Result

    drop: (Array, N = 1) ->
        [V for I, V in pairs Array when I > N]

    takeRight: (Array, N = 1) ->
        Len = #Array
        [V for I, V in pairs Array when I > Len - N]

    last: (Array) ->
        Array[#Array]

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

    sortBy: (Array, Fn) -> -- Returns a sorted copy
        Fn = U.iteratee Fn
        Array = U.clone Array
        Metrics = U.fromPairs U.map U.uniq(Array), (V, ...) -> {V, Fn V, ...}
        table.sort Array, (A, B) -> Metrics[A] < Metrics[B]

        Array

    reverse: (Array) -> -- Returns a backwards copy
        Array = U.clone U.values Array
        
        Result = {}
        while #Array > 0
            table.insert Result, table.remove Array
        
        Result

    fill: (Array, Length, Value = 0) ->
        while #Array < Length
            table.insert Array, Value

        Array

    sample: (Array) -> -- returns a random element from Array
        Array[math.random 1, #Array]

    sampleSize: (Array, N = 1) -> -- Returns random sample
        U.take U.shuffle(Array), N

    takeSample: (Array) ->
        Len = #Array
        return if Len == 0
        table.remove Array, math.random 1, Len

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

    join: (Array, Sep = '') -> -- Concat a table
        table.concat Array, Sep

    pop: (Array) ->
        table.remove Array

    push: (Array, Value) ->
        table.insert Array, Value
        #Array

    insert: (Array, Value) ->
        table.insert Array, Value
        Value

    shift: (Array) ->
        table.remove Array, 1

    unshift: (Array, Value) ->
        table.insert Array, 1, Value

    without: (Array, ...) ->
        U.difference Array, {...}

    pull: (Array, ...) ->
        ToRemove = U.uniq {...}
        I = 1
        while I <= #Array
            for T in *ToRemove
                if Array[I] == T
                    table.remove Array, I
                    I -= 1
            I += 1

        Array

    remove: (Array, Fn) ->
        U.pull Array, unpack U.filter Array, Fn

    -- Objects
    defaults: (Object, Properties) ->
        Object[I] = V for I, V in pairs Properties when Object[I] == nil
        Object

    defaultsDeep: (Object, Properties, Explored = {}) ->
        for I, V in pairs Properties
            T = Object[I]
            if T != nil
                if (type V) == 'table' and (type T) == 'table'
                    if E = Explored[T]
                        return E
                    Explored[T] = '** circular **'
                    U.defaultsDeep T, V, Explored
                    Explored[T] = T
            else Object[I] = U.cloneDeep V
        Object

    merge: (Object, Properties) ->
        Object[I] = V for I, V in pairs Properties
        Object

    keys: (Object) ->
        [I for I in pairs Object]

    -- Experimental
    deconstruct: (Template, Object) ->
        [U.get Object, k for k in *U.sort U.keysDeep Template]

    reconstruct: (Object, Template) ->
        keys = U.sort U.keysDeep Template
        with result = {}
            U.set result, keys[i], v for i, v in pairs Object

    -- Strings
    plural: (S, N) ->
        S .. (N == 1 and '' or 's')

    lower: (S) ->
        S\lower!

    lowerFirst: (S) ->
        S\sub(1,1)\lower! .. S\sub 2

    upper: (S) ->
        S\upper!

    upperFirst: (S) ->
        S\sub(1,1)\upper! .. S\sub 2

    capitalize: (S) ->
        S\sub(1,1)\upper! .. S\sub(2)\lower!

    startsWith: (S, T) ->
        T == S\sub 1, #T

    endsWith: (S, T) ->
        T == S\sub #S - #T + 1

    repeat: (S, N = 1) ->
        S\rep N

    stringify: (A) ->
        switch type A
            when 'table'
                s = nil
                a, z = if U.isArray A
                    s = U.map A, U.stringify
                    '[', ']'
                else
                    s = U.values U.map A, (v, i) -> U.stringify(i).. ': '..U.stringify v
                    '{', '}'
                
                a .. U.join(s, ', ') .. z
            when 'string'
                '"' .. A .. '\"'
            else tostring A
    
    phone: (S) ->
        Substitutions = {
            S\upper!, 'ABC', 'DEF',
            'GHI', 'JKL', 'MNO',
            'PQRS', 'TUV', 'WXYZ'
        }
        U.reduce Substitutions, (S, V, I) -> S\gsub '['..V..']', tostring I

    -- Math
    rr: (val, min, max, change = 0) -> -- round robin
        min + (val + change - min)%(max + 1 - min)

    fromHex: (val) ->
        tonumber val, 16

    isEven: (x) ->
        x%2 == 0

    isOdd: (x) ->
        x%2 == 1

    add: (x, y) -> x + y

    sum: (Array) ->
        U.reduce Array, U.add

    sumBy: (Array, Fn) ->
        Fn = U.iteratee Fn
        U.sum U.map Array, Fn

    multiply: (x, y) -> x * y

    product: (Array) ->
        U.reduce Array, U.multiply

    factorial: (N = 1) ->
        U.product U.range N

    average: (Array) ->
        U.sum(Array)/#Array

    max: (Array) ->
        U.reduce Array, U.ary math.max, 2

    maxBy: (Array, Fn) ->
        Fn = U.iteratee Fn
        Metrics = U.map Array, Fn
        Array[U.reduce Metrics, ((S, V, I) ->
            if V > Metrics[S]
                I
            else S
        )]

    maxKeyBy: (Collection, Fn) ->
        U.maxBy (U.keys Collection), Fn

    min: (Array) ->
        U.reduce Array, U.ary math.min, 2

    minBy: (Array, Fn) ->
        Fn = U.iteratee Fn
        Metrics = U.map Array, Fn
        Array[U.reduce Metrics, ((S, V, I) ->
            if V < Metrics[S]
                I
            else S
        )]

    minKeyBy: (Collection, Fn) ->
        U.minBy (U.keys Collection), Fn

    clamp: (N, Min, Max) ->
        if Max
            math.min Max, math.max Min, N
        else math.min Min, N

    -- Helper
    chain: (Value) ->
        Wrapped =
            chain: true
            wrapped: {}
            target: Value
            plant: (@target) =>
            value: =>
                U.reduce @wrapped, ((s, v) ->
                    U[v.fn] s, unpack v.args
                ), @target

        setmetatable Wrapped,
            __index: (K) =>
                V = rawget @, K
                return V if V != nil
                Fn = U[K]
                assert Fn, 'invalid method in chain: ' .. tostring K
                (...) ->
                    T = with U.clone @
                        .wrapped = U.concat .wrapped, {fn: K, args: {...}}

                    setmetatable T, __index: (getmetatable Wrapped).__index

    nowChain: (Value) ->
        Wrap = U Value
        final = Value
        Wrap.value = -> final

        m = getmetatable Wrap
        old = m.__index
        setmetatable Wrap, __index: (FnName) =>
            if fn = old Wrap, FnName
                (...) -> return U.nowChain fn ...
            else error 'failed to find ' .. FnName

    times: (N, Fn) ->
        [Fn i for i = 1, N]

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
        (...) -> Fn unpack U.take {...}, N

    unary: (Fn) ->
        (V) -> Fn V

    after: (N = 1, Fn) ->
        count = 0
        (...) ->
            count += 1
            if count > N
                Fn ...

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

    over: (Fns) ->
        (...) -> [Fn ... for Fn in *Fns]

    overEvery: (Fns) ->
        (...) ->
            Args = {...}
            U.every Fns, (Fn) -> Fn unpack Args

    overSome: (Fns) ->
        (...) ->
            Args = {...}
            U.some Fns, (Fn) -> Fn unpack Args

    overArgs: (Fn, Transforms) -> -- Fn a, b -> Fn Transforms[1]a, Transforms[2]b
        (...) -> Fn unpack U.map {...}, (V, I) -> Transforms[I] V

    combine: (...) ->
        Fns = {...}
        (...) -> Fn ... for Fn in *Fns

    unbind: (Fn) ->
        (...) => Fn ...

    bind: (Fn, Self) ->
        (...) -> Fn Self, ...

    namecall: (Self, Method) ->
        (...) -> Self[Method] Self, ...

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
    toggle: (state = false) ->
        {
            state: -> state
            toggle: ->
                state = not state
                state
            reset: (to = false) -> state = to
        }

    lock: (state = false) ->
        {
            locked: -> state == true
            lock: -> state = true
            unlock: -> state = false
        }

    counter: (state = 0) ->
        {
            value: -> state
            reset: (to = 0) -> state = to
            count: (amount = 1) ->
                state += amount
                state
        }

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

    memoize: (Getter, State = {}) ->
        isFunction = 'function' == type Getter

        setmetatable State,
            __index: (T, K) ->
                V = rawget T, K
                return V if V != nil
                
                V = if isFunction
                    Getter K, T
                else Getter

                rawset T, K, V
                V

    -- ids
    nonce: (state = 0) ->
        U.counter(state).count

    uniqueId: (prefix = '') ->
        prefix .. U.uniqueCounter.count!

    -- meta
    mixin: (Plugin) -> U.merge U, Plugin

}

-- Aliases
U.head = U.first
U.car = U.first
U.cdr = U.tail
U.defaultdict = U.memoize
U.instantly = U.call -- hi wally

-- Setup
U.uniqueCounter = U.counter!

if game
    with U
        .Service = .defaultdict (K) -> game\GetService K
        if .Service.RunService\IsClient!
            .User = .Service.Players.LocalPlayer

        .waitFor = (object, path, timeout) ->
            U.reduce {object, unpack path}, (o, n) ->
                o\waitForChild n, timeout

        .Instance = (object, properties) ->
            if 'string' == type object
                object = Instance.new object

            if properties
                U.merge object, properties

            object

        .hexColor = (str) ->
            values = { str\match '#?(%x%x)(%x%x)(%x%x)' }
            Color3.fromRGB unpack U.chain(values).fill(3).map(U.fromHex)\value!

setmetatable U, __call: (Value) =>
    with Wrap = {}
        setmetatable Wrap, __index: (FnName) =>
            if Fn = rawget Wrap, FnName
                return Fn 
            
            if Fn = U[FnName]
                return (...) -> Fn Value, ...
            else error 'failed to find ' .. FnName

U

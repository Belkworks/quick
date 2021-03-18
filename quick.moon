-- quick.moon
-- SFZILabs 2020

assertType = (Value, Type, Error) -> assert Type == type(Value), Error
assertTable = (Value, Error) -> assertType Value, 'table', Error

U = {}
U = {

	-- Utility
	ab: (Choice, A, B) -> Choice and A or B

	isArray: (List) ->
		return false unless 'table' == type List
		#List == #[i for i in pairs List]

	isObject: (List) ->
		return false unless 'table' == type List
		not U.isArray List

	values: (List) ->
		assertTable List, "values: expected Table for arg#1, got #{type List}"
		return List if U.isArray List
		[V for _, V in pairs List]

	softCopy: (List) -> {I, V for I, V in pairs List} -- Shallow copy of list

	hardCopy: (List, Explored = {}) -> -- Recursive copy of list
		if 'table' == type List
			return Explored[List] if Explored[List]
			Explored[List] = true
			Result = {U.hardCopy(I), U.hardCopy(V) for I, V in pairs List}
			Explored[List] = Result
			Result
		else List

	-- Collections
	each: (List, Fn) -> -- Runs Fn on each element
		assertTable List, "each: expected Table for arg#1, got #{type List}"
		assertType Fn, 'function', "each: expected Function for arg#2, got #{type Fn}"
		Fn V, I, List for I, V in pairs List
		List
	
	map: (List, Fn) -> -- Returns list of Fn (element)
		assertTable List, "map: expected Table for arg#1, got #{type List}"
		assertType Fn, 'function', "map: expected Function for arg#2, got #{type Fn}"
		{I, Fn V, I, List for I, V in pairs List}

	reduce: (List, Fn, State) -> -- Reduces list to single value, state defaults to first value
		assertTable List, "reduce: expected Table for arg#1, got #{type List}"
		assertType Fn, 'function', "reduce: expected Function for arg#2, got #{type Fn}"
		
		for I, V in pairs List
			State = if State == nil and I == 1 -- skip the first
				V -- default to first value
			else Fn State, V, I, List

		State

	find: (List, Fn) -> -- Returns first value that passes Fn
		assertTable List, "find: expected Table for arg#1, got #{type List}"
		assertType Fn, 'function', "find: expected Function for arg#2, got #{type Fn}"
		return V for I, V in pairs List when Fn V, I, List

	filter: (List, Fn) -> -- Returns each value that passes Fn
		assertTable List, "filter: expected Table for arg#1, got #{type List}"
		assertType Fn, 'function', "filter: expected Function for arg#2, got #{type Fn}"
		[V for I, V in pairs List when Fn V, I, List]

	findWhere: (List, Props) -> -- Returns first object matching properties
		assertTable List, "findWhere: expected Array for arg#1, got #{type List}"
		assertTable Props, "findWhere: expected Object for arg#2, got #{type Props}"
		assert U.isArray(List), "findWhere: expected Array for arg#1, got Object"
		assert U.isObject(Props), "findWhere: expected Object for arg#2, got Array"
		U.find List, (O) -> return false for I, V in pairs Props when O[I] ~= V

	where: (List, Props) -> -- Returns all objects matching properties
		assertTable List, "where: expected Array for arg#1, got #{type List}"
		assertTable Props, "where: expected Object for arg#2, got #{type Props}"
		assert U.isArray(List), "where: expected Array for arg#1, got Object"
		assert U.isObject(Props), "where: expected Object for arg#2, got Array"
		U.filter List, (O) -> return false for I, V in pairs Props when O[I] ~= V

	reject: (List, Fn) -> -- Opposite of filter, returns failed Fn
		assertTable List, "reject: expected Table for arg#1, got #{type List}"
		assertType Fn, 'function', "reject: expected Function for arg#2, got #{type Fn}"
		[V for I, V in pairs List when not Fn V, I, List]

	every: (List, Fn) -> -- Returns true if every element passes Fn
		assertTable List, "every: expected Table for arg#1, got #{type List}"
		assertType Fn, 'function', "every: expected Function for arg#2, got #{type Fn}"
		return false for I, V in pairs List when not Fn V, I, List
		true

	some: (List, Fn) -> -- Returns true if some elements pass Fn
		assertTable List, "some: expected Table for arg#1, got #{type List}"
		assertType Fn, 'function', "some: expected Function for arg#2, got #{type Fn}"
		return true for I, V in pairs List when Fn V, I, List
		false

	indexOf: (List, Element) -> -- Returns index of Element in List
		assertTable List, "indexOf: expected Table for arg#1, got #{type List}"
		return I for I, V in pairs List when V == Element

	contains: (List, Element) -> -- Returns true if List has Element
		assertTable List, "contains: expected Table for arg#1, got #{type List}"
		nil ~= U.indexOf List, Element

	invoke: (List, Method, ...) -> -- Returns list of value[method] ...
		assertTable List, "invoke: expected Table for arg#1, got #{type List}"
		Args = {...}
		U.map List, (V) -> V[Method] unpack Args

	pluck: (List, Key) -> -- Returns list of each value[key]
		assertTable List, "pluck: expected Table for arg#1, got #{type List}"
		U.map List, (V, I) ->
			assertTable V, "pluck: expected Table for element #{I}, got #{type V}"
			V[Key]

	shuffle: (List) -> -- Returns shuffled copy
		assertTable List, "shuffle: expected Array for arg#1, got #{type List}"
		List = U.softCopy U.values List
		Result = {}
		while #List > 1
			table.insert Result, table.remove List, math.random 1, #List
		table.insert Result, List[1]
		Result

	sort: (List, Fn) -> -- Returns a sorted copy
		assertTable List, "sort: expected Array for arg#1, got #{type List}"
		if Fn
			assertType Fn, 'function', "sort: expected Function for arg#2, got #{type Fn}"

		List = U.softCopy U.values List
		table.sort List, Fn
		List

	reverse: (List) -> -- Returns a backwards copy
		assertTable List, "reverse: expected Array for arg#1, got #{type List}"
		List = U.softCopy U.values List
		
		Result = {}
		while #List > 0

			table.insert Result, table.remove List
		
		Result

	sample: (List, N = 1) -> -- Returns random sample
		assertTable List, "sample: expected Array for arg#1, got #{type List}"
		U.first U.shuffle(List), N

	size: (List) -> #U.values List -- Returns count of array/object

	partition: (List, Fn) -> -- Returns list of passing values and list of failing values
		assertTable List, "partition: expected Table for arg#1, got #{type List}"
		assertType Fn, 'function', "partition: expected Function for arg#2, got #{type Fn}"
		Pass, Fail = {}, {}
		for I, V in pairs List
			if Fn V, I, List
				table.insert Pass, V
			else table.insert Fail, V
		Pass, Fail

	compact: (List) -> -- Filter out falsy values
		assertTable List, "compact: expected Table for arg#1, got #{type List}"
		U.filter List, (V) -> V

	first: (List, N = 1) -> -- Get first N of List 
		[V for I, V in pairs List when I <= N]

	join: (List, Sep = '') -> -- Concat a table
		assertTable List, "join: expected Table for arg#1, got #{type Object}"
		assertType Sep, 'string', "join: expected string for arg#1, got #{type S}"
		table.concat List, Sep

	-- Objects
	defaults: (Object, Properties) ->
		assertTable Object, "defaults: expected Table for arg#1, got #{type Object}"
		assertTable Object, "defaults: expected Table for arg#2, got #{type Properties}"
		Object[I] = Properties[I] for I in pairs Properties when Object[I] == nil
		Object

	keys: (Object) ->
		assertTable Object, "keys: expected Table for arg#1, got #{type Object}"
		[I for I in pairs Object]

	-- Strings
	plural: (S, N) ->
		assertType S, 'string', "plural: expected string for arg#1, got #{type S}"
		assertType N, 'number', "plural: expected number for arg#2, got #{type N}"	
		S .. (N == 1 and '' or 's')

	capFirst: (S) ->
		assertType S, 'string', "capFirst: expected string for arg#1, got #{type S}"
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
		assertType N, 'number', "times: expected number for arg#1, got #{type N}"
		assertType Fn, 'function', "times: expected function for arg#2, got #{type Fn}"	
		
		[Fn i for i = 1, N]

	result: (Object, Key, Default) ->
		assertType Object, 'table', "result: expected Table for arg#1, got #{type Object}"
		assert Key != nil, 'result: expected key for arg#2, got nil'

		X = Object[Key]
		return X if X != nil

		Default

	curry: (N, Fn, args = {}) ->
		assertType N, 'number', "curry: expected number for arg#1, got #{type N}"
		assertType Fn, 'function', "curry: expected function for arg#2, got #{type Fn}"	
		(v) ->
			a = [v for v in *args]
			n = N - 1
			if n <= 0
				Fn unpack(a), v
			else
				table.insert a, v
				curry n, Fn, a

	-- debounce(state = false) -> (set = true) -> bool
	debounce: (state = false) ->
		assertType state, 'boolean',
			"debounce: expected boolean for arg#1, got #{type state}"

		(set = true) ->
			if set == false
				state = false
			elseif state
				return true
			else state = true

			not state

	-- rising(state = false) -> (set) -> bool
	rising: (state = false) ->
		assertType state, 'boolean',
			"rising: expected boolean for arg#1, got #{type state}"

		deb = U.debounce state
		(set) -> not deb set

	-- rising(state = false) -> (set) -> bool
	falling: (state = false) ->
		assertType state, 'boolean',
			"falling: expected boolean for arg#1, got #{type state}"

		deb = U.debounce state
		(set) -> not deb not set

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
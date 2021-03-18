
# Quick
*A moonscript port of underscore, containing utilities for functional programming.*

**Importing with [Neon](https://github.com/Belkworks/NEON)**:
```lua
_ = NEON:github('belkworks', 'quick')
```

## API

### Collections

**each**: `_.each(list, fn) -> list`  
Runs `fn` (yielding) on each element in `list`.  
`fn` receives the parameters `(value, key, list)`  
Returns the `list` passed to it.
```lua
_.each({1, 2, 3}, function(v) print(v) end) -- prints each number in {1, 2, 3}
```

**map**: `_.map(list, fn) -> list`  
Like **each**, but maps the results of `fn` into an identically-keyed list.  
`fn` receives the parameters `(value, key, list)`
```lua
_.map({1, 2, 3}, function(v) return v*2 end) -- {2, 4, 6}
```

**reduce**: `_.reduce(list, fn, state) -> value?`  
Like **map**, but returns the last result of `fn`.  
Whatever `fn` returns is the new state in each call.  
If `state` is undefined, `fn` is not called for the first iteration.  
 `state` would instead default to the first element of the list.  
`fn` receives the parameters `(state, value, key, list)`
```lua
_.reduce({1, 2, 3}, function(s, v) return s+v end) -- 6
```

**find**: `_.find(list, fn) -> value?`  
Executes `fn` on each element of `list`.  
Returns the first value that passes `fn`.  
`fn` receives the parameters `(value, key, list)`
```lua
_.find({1, 2, 3}, function(v) return v > 2 end) -- 3
```

**filter**: `_.filter(list, fn) -> array`  
Like **map**, but only keeps values that pass `fn`.  
The original value, however, is unmodified.  
`fn` receives the parameters `(value, key, list)`  
**NOTE**: *Does not return original key!*
```lua
_.filter({1, 2, 3}, function(v) return v > 1 end) -- {2, 3}
```

**findWhere**: `_.findWhere(list, object) -> value?`  
Returns the first object in `list` that matches all keys in `object`
```lua
_.findWhere({{a=1,b=4}, {a=2,b=5}, {a=3,b=6}}, {a=3}) -- {a=3,b=6}
```

**where**: `_.where(list, props) -> array`  
Like **findWhere**, but returns *all* objects that match all keys in `object`
```lua
_.where({{a=1,b=4}, {a=2,b=5}, {a=2,b=6}}, {a=2}) -- {{a=2,b=5}, {a=2,b=6}}
```

**reject**: `_.reject(list, fn) -> array`  
Opposite of **filter**, returns values that don't pass `fn`.  
`fn` receives the parameters `(value, key, list)`
```lua
_.reject({1, 2, 3}, function(v) return v > 1 end) -- {1}
```

**every**: `_.every(list, fn) -> boolean`  
Returns `true` if every value in `list` passes `fn`.  
`fn` receives the parameters `(value, key, list)`
```lua
_.every({1, 2, 3}, function(v) return v > 1 end) -- false
```

**some**: `_.some(list, fn) -> boolean`  
Returns `true` if any value in `list` passes `fn`.  
`fn` receives the parameters `(value, key, list)`
```lua
_.some({1, 2, 3}, function(v) return v > 1 end) -- true
```

**indexOf**: `_.indexOf(list, value) -> integer?`  
Returns the first index of `value` in `list`.  
Returns `nil` if `value` wasn't found.
```lua
_.indexOf({3, 2, 1}, 3) -- 1
```

**contains**: `_.contains(list, value) -> boolean`  
Returns `true` if `list` contains `value`.
```lua
_.contains({1, 2, 3}, 2) -- true
```

**partition**: `_.partition(list, fn) -> array, array`  
Like **filter**, but the second returned array contains values that didn't pass `fn`.
```lua
_.filter({1, 2, 3}, function(v) return v > 1 end) -- {2, 3}, {1}
```

**first**: `_.first(list, N = 1) -> array`  
Returns the first `N` values of `list` as an array.
```lua
_.first({1, 2, 3}, 1) -- {1}
_.first({1, 2, 3}, 2) -- {1, 2}
```

**defaults**: `_.defaults(object, props) -> object`  
Fill in missing properties in `object` from `props`.  
Does not work recursively.  
Returns the modified `object`.
```lua
_.defaults({a=1}, {a=2,b=3}) -- {a=1, b=3}
```

**keys**: `_.keys(list) -> array`  
Returns an array of keys for the given `list`.
```lua
_.keys({a=1, b=3}) -- {'a', 'b'}
```

**result**: `_.result(list, key, default) -> value`  
Returns `list[key]` if it is non-nil or returns `default`
```lua
_.result({a=1, b=3}, 'b', 4) -- 3
_.result({a=1, b=3}, 'c', 4) -- 4
```

### Arrays

**shuffle**: `_.shuffle(array) -> array`  
Returns a shuffled copy of the input `array`.
```lua
_.shuffle({1,2,3}) -- {3, 1, 2}
```

**reverse**: `_.reverse(array) -> array`  
Returns a reversed copy of the input `array`.
```lua
_.reverse({1,2,3}) -- {3, 2, 1}
```

**sample**: `_.sample(array, N = 1) -> array`  
Returns N elements randomly chosen from `array`.
```lua
_.sample({1,2,3}) -- {2}
_.sample({1,2,3}, 2) -- {3, 1}
```

**compact**: `_.compact(array) -> array`  
Returns a copy of `array` with falsy values filtered out.
```lua
_.compact({1, nil, 2, false, 3}) -- {1, 2, 3}
```

**join**: `_.join(array, sep = '') -> string`  
Shorthand for `table.concat(array, sep)`
```lua
_.join({1, 2, 3}) -- '123'
_.join({1, 2, 3}, ' ') -- '1 2 3'
_.join({1, 2, 3}, ', ') -- '1, 2, 3'
```

### Strings

**plural**: `_.plural(str, num) -> string`  
Returns `str` with an appended `s` if `num` is not 1.
```lua
_.plural('piece', 2) -- 'pieces'
_.plural('piece', 1) -- 'piece'
_.plural('piece', 0) -- 'pieces'
```

**capFirst**: `_.capFirst(str) -> string`  
Returns `str` but with the first letter capitalized.
```lua
_.capFirst('apple') -- 'Apple'
```

**stringify**: `_.stringify(value) -> string`  
Turns any value into a readable string.
```lua
_.stringify('apple') -- '"apple"'
_.stringify({1,2,3}) -- '[1, 2, 3]'
_.stringify({a=1, b=2}) -- '{"a": 1, "b": 2}'
```

### Math

**rr**: `_.rr(value, min, max, change = 0) -> number`  
Round-robin `value + change` to be within `min` and `max` (inclusive).  
Returns the bounded number.
```lua
_.rr(2, 1, 10) -- 2
_.rr(1, 1, 10) -- 1
_.rr(10, 1, 10) -- 10
_.rr(11, 1, 10) -- 1
_.rr(10, 1, 10, 1) -- 1
_.rr(8, 1, 10, 3) -- 1
```

### Utilities

**times**: `_.times(num, fn) -> array`  
Calls `fn` `num` times, with the current execution passed to `fn` as its only parameter.  
Returns the results of those calls as an array.
```lua
_.times(3, function(i) return i*2 end) -- {2, 4, 6}
```

**curry**: `_.curry(num, fn, args = {}) -> function`  
Returns a [curried](https://drboolean.gitbooks.io/mostly-adequate-guide-old/content/ch4.html) version of `fn` that will receive `num` args.
```lua
plural = _.curry(2, _.plural)
pieces = plural('pieces')
pieces(2) -- 'pieces'
pieces(1) -- 'piece'
pieces(0) -- 'pieces'
```

**chain**: `_.chain(value) -> object`  
Allows fluent method chaining on a value.  
Each subsequent call is wrapped in a new `chain`.  
Use the `.value()` function to get the value from a chain.
```lua
list = _.chain({1, 2, 3})
reversed = list.reverse()
doubled = reversed.map(function(v) return v*2 end)
doubledReversed = doubled.value() -- {6, 4, 2}

-- you don't need to assign the result to a variable
double = function(v) return v*2 end
doubledReversed = _.chain({1, 2, 3}).reverse().map(double).value() -- {6, 4, 2}
```

**debounce**: `_.debounce(state = false) -> (new = true) -> boolean`  
Create a debouncer with a predetermined `state`.  
Returns a function that takes a parameter, `new`, which will set the internal state.  
Call the debounce with `false` to clear the state.  
Otherwise, a truthy value will set the state.
Returns `true` if the debouncer was already set.
```lua
deb = _.debounce()
deb() -- false
deb() -- true
deb() -- true
deb(false) -- true, unsets debounce
deb() -- false

-- example
deb = _.debounce()
function doSomething()
    if deb() then return end -- debounce is now enabled
    -- do some work
    deb(false) -- unset the debounce
end
doSomething()
```

**rising**: `_.rising(state = false) -> (set) -> boolean`  
A rising edge detector.  
Returns a function that takes an input, `set`, and outputs whether it is the first rising value.  
Uses `_.debounce` internally.
```lua
up = _.rising()
up(false) -- false
up(true) -- true
up(true) -- false
up(false) -- false
up(true) -- true
```

**falling**: `_.falling(state = true) -> (set) -> boolean`  
A Falling edge detector.  
Returns a function that takes an input, `set`, and outputs whether it is the first falling value.  
Uses `_.debounce` internally.
```lua
down = _.falling()
down(false) -- true
down(true) -- false
down(true) -- false
down(false) -- true
down(true) -- false
```

### OOP Style

You can wrap a value with quick functions by calling `_(value)`.  
The wrapped value will be passed as the first argument for you.  
This is used internally by `_.chain`.
```lua
wrapped = _({1, 2, 3})
reversed = wrapped.reverse() -- {3, 2, 1}
-- reverse receives the wrapped value
```


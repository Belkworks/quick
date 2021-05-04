
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

**filter**: `_.filter(list, fn) -> array`  
Like **map**, but only keeps values that pass `fn`.  
`fn` is transformed through `_.iteratee`.  
The original value, however, is unmodified.  
`fn` receives the parameters `(value, key, list)`  
**NOTE**: *Does not return original key!*
```lua
_.filter({1, 2, 3}, function(v) return v > 1 end) -- {2, 3}
```

**reject**: `_.reject(list, fn) -> array`  
Opposite of **filter**, returns values that don't pass `fn`.  
`fn` is transformed through `_.iteratee`.  
`fn` receives the parameters `(value, key, list)`
```lua
_.reject({1, 2, 3}, function(v) return v > 1 end) -- {1}
```

**partition**: `_.partition(list, fn) -> array, array`  
Like **filter**, but the second returned array contains values that didn't pass `fn`.  
`fn` is transformed through `_.iteratee`.  
```lua
_.partition({1, 2, 3}, function(v) return v > 1 end) -- {2, 3}, {1}
```

**find**: `_.find(list, fn) -> value?`  
Executes `fn` on each element of `list`.  
`fn` is transformed through `_.iteratee`.  
Returns the first value that passes `fn`.  
`fn` receives the parameters `(value, key, list)`
```lua
_.find({1, 2, 3}, function(v) return v > 2 end) -- 3
```

**findIndex**: `_.findIndex(list, fn) -> number?`  
Like **find**, but returns the index instead of the value.  
`fn` is transformed through `_.iteratee`.  
`fn` receives the parameters `(value, key, list)`
```lua
_.findIndex({4, 5, 6}, function(v) return v == 5 end) -- 2
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

**every**: `_.every(list, fn) -> boolean`  
Returns `true` if every value in `list` passes `fn`.  
`fn` is transformed through `_.iteratee`.  
`fn` receives the parameters `(value, key, list)`
```lua
_.every({1, 2, 3}, function(v) return v > 1 end) -- false
```

**some**: `_.some(list, fn) -> boolean`  
Returns `true` if any value in `list` passes `fn`.  
`fn` is transformed through `_.iteratee`.  
`fn` receives the parameters `(value, key, list)`  
Returns the opposite of `_.none`
```lua
_.some({1, 2, 3}, function(v) return v > 1 end) -- true
```

**none**: `_.none(list, fn) -> boolean`  
Returns `true` if no value in `list` passes `fn`.  
`fn` is transformed through `_.iteratee`.  
`fn` receives the parameters `(value, key, list)`  
Returns the opposite of `_.some`
```lua
_.none({1, 2, 3}, function(v) return v > 1 end) -- false
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

**pick**: `_.pick(list, keys) -> list`  
Returns a selection of `list` based on `keys`.  
```lua
_.pick({a=1,b=2,c=3}, {'a', 'c'}) -- {a=1, c=3}
```

**omit**: `_.omit(list, keys) -> list`  
Like **pick**, but selects keys that are not in `keys`.  
Slower than **pick**
```lua
_.pick({a=1,b=2,c=3}, {'a', 'c'}) -- {b=2}
```

**toPairs**: `_.toPairs(list) -> list`  
Turns `list` into an array of key-value pairs.
```lua
_.toPairs({'a', 'b', 'c'}) -- {{1,'a'}, {2,'b'}, {3,'c'}}
```

**fromPairs**: `_.fromPairs(list) -> list`  
The opposite of **toPairs**.  
Returns a list composed of `e[1] -> e[2]` for every element `e` in `list`.
```lua
_.fromPairs({{1,'a'}, {2,'b'}, {3,'c'}}) -- {'a', 'b', 'c'}
```

### Arrays

**chunk**: `_.chunk(array, size = 1) -> array`  
Groups elements of `array` into sub arrays of size `size`.  
The last subarray contains the remainder.
```lua
T = _.range(10) -- {1, 2, 3, 4, 5...10}
_.chunk(T, 3) -- {1,2,3}, {4,5,6}, {7,8,9}, {10}
```

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

**sample**: `_.sample(array) -> value`  
Returns a random element chosen from `array`.
```lua
_.sample({1,2,3}) -- 2
_.sample({1,2,3}) -- 3
```

**sampleSize**: `_.sampleSize(array, N = 1) -> array`  
Returns `N` elements randomly chosen from `array`.
```lua
_.sampleSize({1,2,3}) -- {2}
_.sampleSize({1,2,3}, 2) -- {3, 1}
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

**uniq**: `_.uniq(array) -> array)`  
Returns an array containing no duplicates.  
```lua
_.uniq({1,2,3,1,2}) -- {1, 2, 3}
```

**concat**: `_.concat(array, ...elements) -> array`  
Returns a copy of `array` with each additional argument appended.  
If an argument is an array, its contents will be appended.
```lua
_.concat({1,2,3}, 4, {5, 6}) -- {1, 2, 3, 4, 5, 6}
```

**initial**: `_.initial(array) -> array`  
Returns an array of all but the last elements of `array`.
```lua
_.initial({1, 2, 3}) -- {1, 2}
```

**tail**: `_.tail(array) -> array`  
Returns an array of all but the first element of `array`.
```lua
_.tail({1, 2, 3}) -- {2, 3}
```

**take**: `_.take(array, n = 1) -> array`  
Returns an array of `n` elements of `array`.
```lua
_.take({1, 2, 3}, 2) -- {1, 2}
```

**takeRight**: `_.takeRight(array, n = 1) -> array`  
Like **take**, but starts from the right.
```lua
_.takeRight({1, 2, 3}, 2) -- {2, 3}
```

**first**: `_.first(array) -> element?`  
Returns the first element of `array`
```lua
_.first({1, 2, 3}) -- 1
```

### Strings

**plural**: `_.plural(str, num) -> string`  
Returns `str` with an appended `s` if `num` is not 1.
```lua
_.plural('piece', 2) -- 'pieces'
_.plural('piece', 1) -- 'piece'
_.plural('piece', 0) -- 'pieces'
```

**upperFirst**: `_.upperFirst(str) -> string`  
Returns `str` but with the first letter capitalized.
```lua
_.upperFirst('apple') -- 'Apple'
```

**lowerFirst**: Like **upperFirst** but lowercase  
**capitalize**: Like **upperFirst** but the rest of the string is lowercase  

**startsWith**: `_.startsWith(str, target) -> boolean`  
Returns `true` if `str` starts with `target`
```lua
_.startsWith('test123', '123') -- true
```

**endsWith**: Like **startsWith**, but checks at the end.  

**stringify**: `_.stringify(value) -> string`  
Turns any value into a readable string.
```lua
_.stringify('apple') -- '"apple"'
_.stringify({1,2,3}) -- '[1, 2, 3]'
_.stringify({a=1, b=2}) -- '{"a": 1, "b": 2}'
```

**phone**: `_.phone(string) -> string`  
Turns any phone word into a phone number.
```lua
_.phone('1-800-scripts') -- '1-800-7274787'
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

**sum**: `_.sum(array) -> number`  
Returns the sum of all elements in `array`.
```lua
_.sum({1,2,3}) -- 6
```

**average**: `_.average(array) -> number`  
Returns the average of all elements in `array`.
```lua
_.average({1,2,3}) -- 2
```

**product**: `_.product(array) -> number`  
Returns the product of all elements in `array`.
```lua
_.product({1,2,3}) -- 6
```

**factorial**: `_.factorial(num) -> number`  
Returns the factorial of `num`.
```lua
_.factorial(3) -- 6
```

**max**: `_.max(array) -> number`  
Returns the largest element in `array`.
```lua
_.max({1,2,3}) -- 3
```

**maxBy**: `_.maxBy(array, fn) -> value`  
Returns the largest element in `array` attained by `fn`.  
`fn` is transformed through `_.iteratee`.  
`fn` receives the parameters `(value, key, list)`  
```lua
_.maxBy({'test', 'abc'}, string.len) -- 'test'
```

**min**: `_.min(array) -> number`  
Returns the smallest element in `array`.
```lua
_.min({1,2,3}) -- 1
```

**minBy**: `_.minBy(array, fn) -> value`  
Like **maxBy**, but returns the *smallest* value in `array` attained by `fn`.  
`fn` is transformed through `_.iteratee`.  
`fn` receives the parameters `(value, key, list)`  
```lua
_.minBy({'test', 'abc'}, string.len) -- 'abc'
```

**clamp**: `_.clamp(num, max) -> number`  
Returns `max` if `num` is greater than `max`  
**clamp**: `_.clamp(num, min, max) -> number`  
Returns `min` if `num` is less than `min`.  
Returns `max` if `num` is greater than `max`.

```lua
_.clamp(2, 5, 7) -- 5
_.clamp(2, 5) -- 2
_.clamp(6, 5) -- 5
_.clamp(10, 5, 7) -- 7
```

### Utilities

**isEqual**: `_.isEqual(a, b) -> boolean`  
Returns whether `a` and `b` are deep equals.  
Useful for comparing tables.
```lua
a = {1, 2}
b = {1, 2}
a == b -- false
_.isEqual(a, b) -- true
```

**clone**: `_.clone(list) -> list`  
Returns a shallow copy of `list`.
```lua
_.clone({1,2,3}) -- {1, 2, 3}
```

**cloneDeep**: `_.cloneDeep(list) -> list`  
Returns a deep copy of `list`.
```lua
_.clone({1,2,{1,2}}) -- {1, 2, {1,2}}
```

**chain**: `_.chain(value) -> object`  
Allows fluent method chaining on a value.  
Each subsequent call is wrapped in a new `chain`.  
Use the `:value()` method to execute the chain and get the result.
```lua
list = _.chain({1, 2, 3})
-- equivalent to
list = _({1,2,3}).chain()

reversed = list.reverse()
doubled = reversed.map(function(v) return v*2 end)
doubledReversed = doubled:value() -- {6, 4, 2}

-- you don't need to assign each step to a variable
double = function(v) return v*2 end
doubledReversed = _.chain({1, 2, 3}).reverse().map(double):value() -- {6, 4, 2}
```

**iteratee**: `_.iteratee(any) -> function`  
Returns a function based on the input type of `any`.  
`String -> _.property(any)`  
`Function -> any`  
`Table -> _.matcher(any)`  
`nil -> _.identity`  
This function can then be applied to a value.  
Used internally by `filter`, `find`, `findIndex`, `map`, `partition`, `reject`, `some`, `none`, and`every`.

**property**: `_.property(path) -> (list) -> value?`  
Returns a function that indexes `list` with `path`.  
If `path` is an array, it will be iterated on the object.  
```lua
_.property('a')({a=1}) -- 1
_.property({'a','b'})({a={b=2}}) -- 2
```

**isMatch**: `_.isMatch(object, props) -> boolean`  
Returns `true` if `object` meets all properties in `props`.  
Supports nested tables.
```lua
_.isMatch({a=1}, {a=1,b=2}) -- true
_.isMatch({a=1,b={1}}, {a=1,b={1}}) -- true
```

**matcher**: `_.matcher(props) -> (object) -> boolean`  
Returns a function that returns `true` if `object` meets all properties in `props`.  
Uses `_.isMatch` internally.  
```lua
_.matcher({a=1})({a=1,b=2}) -- true
_.matcher({a=1,b={1}})({a=1,b={1}}) -- true
```

**times**: `_.times(num, fn) -> array`  
Calls `fn` `num` times, with the current execution passed to `fn` as its only parameter.  
Returns the results of those calls as an array.
```lua
_.times(3, function(i) return i*2 end) -- {2, 4, 6}
```

**range**: `_.range(max, min = 1, step = 1) -> array`  
Returns an array of numbers from `min` to `max`
```lua
_.range(3) -- {1, 2, 3}
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

**uncurry**: `_.uncurry(function) -> (...) -> value`  
Returns a runner for `fn` that will run a curried function in one call.
```lua
add = function(x)
    return function(y) return x + y end
end
_.uncurry(add)(1, 2) -- 3 
```

**unary**: `_.unary(fn) -> function(v) -> fn(v)`  
Returns a function that calls `fn` with only the first parameter passed to it.
```lua
printFirst = _.unary(print)
printFirst(3, 2, 1) -- prints 3
```

**ary**: `_.ary(n = 1, fn) ->  function`  
Like **unary**, but you can specify how many arguments to pass.
```lua
printFirst = _.ary(2, print)
printFirst(4, 5, 6) -- prints 4 5
```

**nthArg**: `_.nthArg(n = 1) -> (...) -> value?`  
Returns a function that returns the `n`th argument passed to it.
```lua
getSecondArg = _.nthArg(2)
getSecondArg(4, 5, 6) -- prints 5
```

**once**: `_.once(fn) -> (...) -> value?`  
Returns a function that only runs `fn` once.  
All subsequent calls return the original return value.
```lua
addOnce = _.once(_.add)
addOnce(1, 2) -- 3
addOnce(3, 4) -- 3
```

**before**: `_.before(n = 1, fn) -> (...) -> value?`  
Like **once**, but you can specify how many times the function can be ran via `n`.  
After `n` executions it returns `fn`'s last return values.
```lua
addTwice = _.before(2, _.add)
addOnce(1, 2) -- 3
addOnce(3, 4) -- 7
addOnce(5, 6) -- 7
```

**after**: `_.after(n = 1, fn) -> (...) -> value?`  
The opposite of **before**.  
Returns a function that only runs `fn` when called `n` or more times.  
Returns `nil` until the function is executed `n` times.
```lua
doNothingFirst = _.after(1, _.add)
addOnce(1, 2) -- nil
addOnce(3, 4) -- 7
addOnce(5, 6) -- 11
```

**combine**: `_.combine(...fns) -> function`  
Returns a function that runs all the given functions.
```lua
printwarn = _.combine(print, warn)
printwarn('hello world') -- prints and warns 'hello world'
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
down(false) -- true
down(false) -- false
down(true) -- false
```

### Data Structures

**defaultdict**: `_.defaultdict(getter, state = {}) -> defaultdict`  
Returns `state`, with a index hook that defaults values to `getter`.
```lua
startAtOne = _.defaultDict(1)
print(startAtOne.test) -- 1
startAtOne.test = 0
print(startAtOne.test) -- 0
startAtone.test = nil
print(startAtOne.test) -- 1
```
If `getter` is a function, it will be called when filling a value.  
`getter` will receive `(key, state)` as its parameters.
```lua
capKey = _.defaultDict(_.capitalize)
print(capKey.jeff) -- 'Jeff'
capKey.jeff = 123
print(capKey.jeff) -- 123
```

**counter**: `_.counter(count = 0) -> Counter`  
Returns a Counter that starts at `count`.  
Counter has the following methods:  
`value() -> number`: Returns the current count.  
`reset(to = 0) -> nil`: Sets the counter to `to`.  
`count(amount = 1) -> number`: Increments count by `amount`, returns new count.
```lua
counter = _.counter()
counter.count() -- 1
counter.value() -- 1
counter.count(2) -- 3
counter.reset()
counter.value() -- 0
```

**lock**: `_.lock(state = false) -> Lock`  
Returns a Lock that starts at `state`.  
Similar in usage to **debounce**.  
Lock has the following methods:  
`locked() -> boolean`: Returns if the lock is set.  
`unlock() -> nil`: Unlocks the lock.  
`lock()`: Locks the lock.
```lua
locker = _.lock()
locker.lock()
locker.locked() -- true
locker.unlock()
locker.locked() -- false
```

**stack**: `_.stack(state = {}) -> Stack`  
Returns a Stack that starts at `state`.  
Stack has the following methods:  
`isEmpty() -> boolean`: Returns whether the stack is empty.  
`push(element) -> number`: Pushes `element` onto the stack, returns the new length.  
`pop() -> element`: Returns (and removes) the element at the top of the stack.  
`peek() -> element`: Like `pop`, but doesn't remove it.  
The Stack's internal state can be accessed via the `state` property.
```lua
s = _.stack()
s.push(5) -- 1
s.push(4) -- 2
s.push(3) -- 3
s.pop() -- 3
s.peek() -- 4
s.pop() -- 4
```

**queue**: `_.queue(state = {}) -> Queue`  
Returns a Queue that starts at `state`.  
Queue has the following methods:  
`isEmpty() -> boolean`: Returns whether the queue is empty.  
`push(element) -> number`: Pushes `element` onto the queue, returns the new length.  
`next() -> element`: Returns (and removes) the next element in the queue.  
`peek() -> element`: Like `next`, but doesn't remove it.  
The Queue's internal state can be accessed via the `state` property.
```lua
q = _.queue()
q.push(5) -- 1
q.push(4) -- 2
q.push(3) -- 3
q.next() -- 5
q.peek() -- 4
q.next() -- 4
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

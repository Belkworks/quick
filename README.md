

> Written with [StackEdit](https://stackedit.io/).
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

**map**: `_.map(list, fn)`  
Like **each**, but maps the results of `fn` into an identically-keyed list.  
`fn` receives the parameters `(value, key, list)`
```lua
_.map({1, 2, 3}, function(v) return v*2 end) -- {2, 4, 6}
```

**reduce**: `_.reduce(list, fn, state) -> value`  
Like **map**, but returns the last result of `fn`.  
Whatever `fn` returns is the new state in each call.  
If `state` is undefined, `fn` is not called for the first iteration.  
 `state` would instead default to the first element of the list.  
`fn` receives the parameters `(state, value, key, list)`
```lua
_.reduce({1, 2, 3}, function(s, v) return s+v end) -- 6
```

**find**: `_.find(list, fn) -> value`  
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

**findWhere**: `_.findWhere(list, object) -> value`  
Returns the first object in `list` that matches all keys in `object`
```lua
_.findWhere({{a=1,b=4}, {a=2,b=5}, {a=3,b=6}}, {a=3}) -- {a=3,b=6}
```

**where**: `_.where(list, props) -> array`  
Like **findWhere**, but returns *all* objects that match all keys in `object`
```lua
_.findWhere({{a=1,b=4}, {a=2,b=5}, {a=2,b=6}}, {a=2}) -- {{a=2,b=5}, {a=2,b=6}}
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

**contains**: `_.contains(list, value) -> boolean`  
Returns `true` if `list` contains `value`.
```lua
_.contains({1, 2, 3}, 2) -- true
```



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
`fn` receives the parameters `(value, key, list`)  
Returns the `list` passed to it.
```lua
_.each({1, 2, 3}, function(v) print(v) end) -- prints each number in {1, 2, 3}
```

**map**: `_.map(list, fn)`  
Like **each**, but maps the results of `fn` into an identically-keyed list.  
`fn` receives the parameters `(value, key, list`)
```lua
_.map({1, 2, 3}, function(v) return v*2 end) -- {2, 4, 6}
```

**reduce**: `_.reduce(list, fn, state) -> value`  
Like **map**, but returns the last result of `fn`.  
Whatever `fn` returns is the new state in each call.  
If `state` is undefined, `fn` is not called for the first iteration.  
 `state` would instead default to the first element of the list.  
`fn` receives the parameters `(state, value, key, list`)
```lua
_.reduce({1, 2, 3}, function(s, v) return s+v end) -- 6
```

**find**: `_.find(list, fn) -> value`  
Executes `fn` on each element of `list`.  
Returns as soon as `fn` returns a truthy value.  
`fn` receives the parameters `(value, key, list`)
```lua
_.find({1, 2, 3}, function(v) return v > 2 end) -- 3
```

**filter**: `_.filter(list, fn) -> array`  
Like **map**, but only keeps values that pass `fn`.  
The original value, however, is unmodified.
`fn` receives the parameters `(value, key, list`)  
**NOTE**: *Does not yet support dictionaries!*
```lua
_.filter({1, 2, 3}, function(v) return v > 1 end) -- {2, 3}
```

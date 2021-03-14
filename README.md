

> Written with [StackEdit](https://stackedit.io/).
# Quick
*A moonscript port of underscore, containing utilities for functional programming.*

**Importing with [Neon](https://github.com/Belkworks/NEON)**:
```lua
_ = NEON:github('belkworks', 'quick')
```

## API

### Collections

**each**: `_.each(list, fn)`
Runs `fn` (yielding) on each element in `list`.
`fn` receives the parameters `(value, key, list`)
```lua
_.each({1, 2, 3}, function(v) print(v) end) -- prints each number in {1, 2, 3}
```

**map**: `_.map(list, fn)`
Like **each**, but maps the results of `fn` into an identically-keyed list.
`fn` receives the parameters `(value, key, list`)
```lua
_.map({1, 2, 3}, function(v) return v*2 end) -- {2, 4, 6}
```

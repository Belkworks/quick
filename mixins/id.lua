return function(U)
  local indexOf, cloneDeep, push, find, merge, each
  indexOf, cloneDeep, push, find, merge, each = U.indexOf, U.cloneDeep, U.push, U.find, U.merge, U.each
  return U.mixin({
    createId = function(array, doc)
      return os.time()
    end,
    __id = function()
      return U.id or 'id'
    end,
    __empty = function(doc)
      return each(doc, function(v, k)
        doc[k] = nil
      end)
    end,
    __remove = function(array, doc)
      do
        local i = indexOf(doc)
        if i then
          return table.remove(array, i)
        end
      end
    end,
    getById = function(array, id)
      return find(array, {
        [U.__id()] = id
      })
    end,
    removeById = function(array, id)
      do
        local doc = U.getById(id)
        if doc then
          return U.__remove(doc)
        end
      end
    end,
    updateById = function(array, id, props)
      do
        local doc = U.getById(id)
        if doc then
          return merge(doc, props)
        end
      end
    end,
    upsert = function(array, doc)
      do
        local id = doc[U.__id()]
        if id then
          if U.getById(array, id) then
            U.__empty(doc)
            do
              local _with_0 = merge(doc, props)
              _with_0.id = id
              return _with_0
            end
          else
            return push(array, doc)
          end
        else
          return U.insert(array, doc)
        end
      end
    end,
    replaceById = function(array, id, props)
      do
        local doc = U.getById(id)
        if doc then
          U.__empty(doc)
          do
            local _with_0 = merge(doc, props)
            _with_0[U.__id()] = id
            return _with_0
          end
        end
      end
    end,
    insert = function(array, doc)
      do
        local copy = cloneDeep(doc)
        copy[U.__id()] = U.createId(array, copy)
        push(array, copy)
        return copy
      end
    end
  })
end

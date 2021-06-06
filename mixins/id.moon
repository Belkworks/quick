(U) ->
	import indexOf, cloneDeep, push, find, merge, each from U

	U.mixin {
		createId: (array, doc) -> os.time!
		__id: -> U.id or 'id'

		__empty: (doc) -> each doc, (v, k) -> doc[k] = nil
		__remove: (array, doc) ->
			if i = indexOf doc
				table.remove array, i

		getById: (array, id) ->
			find array, [U.__id!]: id

		removeById: (array, id) ->
			if doc = U.getById id
				U.__remove doc

		updateById: (array, id, props) ->
			if doc = U.getById id
				merge doc, props

		upsert: (array, doc) ->
			if id = doc[U.__id!]
				if U.getById array, id
					U.__empty doc
					with merge doc, props
						.id = id
				else push array, doc
			else U.insert array, doc

		replaceById: (array, id, props) ->
			if doc = U.getById id
				U.__empty doc
				with merge doc, props
					[U.__id!] = id

		insert: (array, doc) ->
			with copy = cloneDeep doc
				[U.__id!] = U.createId array, copy
				push array, copy
	}

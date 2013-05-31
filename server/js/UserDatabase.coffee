'''
  Simple wrapper for a taffy database. 

  Might be extended to back up the database to local storage, a zip file, etc.
'''
class window.UserDatabase

  constructor: ->
    @database = TAFFY()

  toString: (pretty) =>
    if pretty
      return JSON.stringify(@database().get(), null, 4)
    return @database().stringify()

  fromJSONArray: (array) =>
    @database.insert(array)

  runQuery: (query) =>
    code = "(function(db) { " + query + " }).call(null, this.database)"
    return eval(code)

  clear: =>
    @database().remove()


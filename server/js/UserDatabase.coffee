'''
  Simple wrapper for a taffy database. 

  Might be extended to back up the database to local storage, a zip file, etc.
'''
class window.UserDatabase

  constructor: ->
    # @database = TAFFY()
    @database = TAFFY([
      {"id":1,"gender":"M","first":"John","last":"Smith","city":"Seattle, WA","status":"Active"},
      {"id":2,"gender":"F","first":"Kelly","last":"Ruth","city":"Dallas, TX","status":"Active"},
      {"id":3,"gender":"M","first":"Jeff","last":"Stevenson","city":"Washington, D.C.","status":"Active"},
      {"id":4,"gender":"F","first":"Jennifer","last":"Gill","city":"Seattle, WA","status":"Active"}
    ])

  toString: (pretty) =>
    if pretty
      return JSON.stringify(@database().get(), null, 4)
    return @database().stringify()

  fromJSONArray: (array) =>
    @database.insert(array)

  runQuery: (query) =>
    code = "(function() { " + query + " }).call({ db: this.database })"
    return eval(code)


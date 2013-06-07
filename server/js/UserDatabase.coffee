'''
  Simple wrapper for a taffy database. 

  Might be extended to back up the database to local storage, a zip file, etc.
'''
class window.UserDatabase extends Backbone.Model

  initialize: ->
    @database = TAFFY()

  initLocalStorage: (namespace) =>
    @database.store(namespace + "-UserDatabase")
    @trigger("initLocalStorage")

  toString: (pretty) =>
    if pretty
      return JSON.stringify(@database().get(), null, 4)
    return @database().stringify()

  fromJSONArray: (array) =>
    @database.insert(array)

  runQuery: (query) =>
    code = "(function(database) { " + query + " }).call(null, this.database)"
    return eval(code)

  clear: =>
    @database().remove()


'''
  Simple wrapper for a taffy database. 

  Might be extended to back up the database to local storage, a zip file, etc.
'''
class window.UserDatabase

  constructor: ->
    @database = TAFFY();
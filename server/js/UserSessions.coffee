'''
  Simple wrapper for user sessions.
'''
class window.UserSessions

  # TODO include secret key.
  constructor: ->
    @sessions = {}
    @randomVal = CryptoJS.lib.WordArray.random(128/8)  # TODO make it more secure.
    @hash = CryptoJS.SHA256

  addSession: (sessionId) =>
    @sessions[@hash(sessionId + "" + @randomVal)] = {}

  removeSession: (sessionId) =>
    delete @sessions[@hash(sessionId + "" + @randomVal)]

  getSession: (sessionId) =>
    return @sessions[@hash(sessionId + "" + @randomVal)] 



class window.FileStore
  constructor: ->
    console.log "FileStore initializing"
    @fileList = {}
    @triggerFor = {}
    @recallFromLocalStorage()

  # NOTE: This file may be a file of the same name as an existing file, in which case
  #  the existing file will be overwritten.
  addFile: (name, size, type, contents) =>
    console.log type
    @fileList[name] = 
      "name": name
      "size": size
      "type": type
      "contents": contents
    @saveLocally()
    @trigger("fileStore:fileAdded", {"name": name})

  # Trigger the event on all callbacks registered to be notified.
  trigger: (eventName, data) =>
    callbacks = @triggerFor[eventName]
    if callbacks
      for callback in callbacks
        callback(data)

  # Simple way of registering to listen to an event on the filestore, 
  #   ie a file being added/removed. 
  registerForEvent: (eventName, callback) =>
    if not @triggerFor[eventName]
      @triggerFor[eventName] = []
    @triggerFor[eventName].push(callback)

  getFileContents: (name) =>
    console.log @fileList
    console.log name
    console.log "INDEX OF &AMP"
    console.log @fileList[name].contents.indexOf("&amp")
    return @fileList[name].contents

  getFileSize: (name) =>
    return @fileList[name].size

  getFileType: (type) =>
    return @fileList[name].type

  getFileEntry: (name) =>
    return @fileList[name]

  # Returns true if the filename exists in the filestore, else false
  hasFile: (name) =>
    return name of @fileList

  # Returns an array containing all of the file names in the file store
  fileNames: =>
    return Object.keys(@fileList)

  # Save the current fileList datastructure to local storage
  saveLocally: =>
    localStorage['fileList'] = JSON.stringify(@fileList)
    console.log("saved fileStore to local storage")

  recallFromLocalStorage: =>
    try
      @fileList = JSON.parse(localStorage['fileList'])
      console.log("recalled fileStore from local storage")
    catch e
      console.log ("unable to recall fileStore from local storage")
 
  clear: =>
    @fileList = {}
    localStorage.removeItem("fileList")


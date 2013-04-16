class window.FileStore
  constructor: ->
    console.log "FileStore initializing"
    @fileList = {};

  addFile: (name, size, type, contents) =>
    @fileList[name] = 
      "name": name
      "size": size
      "type": type
      "contents": contents

  getFileContents: (name) =>
    console.log @fileList
    console.log name
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
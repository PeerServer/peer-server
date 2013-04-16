class window.FileStore
	constructor: ->
		console.log "FileStore initializing"
		@fileList = {};

	addFile: (name, contents) =>
		@fileList[name] = contents

	getFile: (name) =>
		return @fileList[name]

  # Returns an array containing all of the file names in the file store
	fileNames: =>
		return Object.keys(@fileList)
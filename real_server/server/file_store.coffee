class window.FileStore
	constructor: ->
		console.log "FileStore initializing"
		@fileList = [];

	addFile: (name, contents) =>
		@fileList[name] = contents

	getFile: (name) =>
		return @fileList[name]

	fileNames: =>
		return Object.keys(@fileList)
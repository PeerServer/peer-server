
class window.FileHandler

    constructor: (@output) ->
        # Make sure data transfer info is sent when item is dropped in


    handleDrop: (event) =>
        console.log "Drop event"
        console.log event
        droppedFiles = event.originalEvent.dataTransfer.files
        console.log droppedFiles
        if droppedFiles.length > 1
            console.error "Only handling one file for now."
        file = droppedFiles[0]
        console.log "processing " + file.name
        reader = new FileReader()
        console.log reader
        reader.readAsText(file)  # Set the mode and the file
        reader.onload = (evt) =>
            console.log "reader loaded"
            text = evt.target.result  # Result of the text file.
            console.log text
            @output.val(text)



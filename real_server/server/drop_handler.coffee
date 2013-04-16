class window.DropHandler
    constructor: (@file_store, @file_name_list, @file_name_view, @file_contents_view) ->
        # Just setting up instance variables for now

    updateListView: (file_name) =>
        console.log "updating list view!!"
        console.log ' ' + @file_store.fileNames()
        @file_name_list.empty()
        for idx,name of @file_store.fileNames()
            console.log 'file:' + name
            @file_name_list.append('<option value="' + name + '">' + name + '</li>')
        @file_name_list.val(file_name)

    handleDrop: (event) =>
        droppedFiles = event.originalEvent.dataTransfer.files
        console.log "processing dropped files:" + droppedFiles
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
            @file_store.addFile(file.name, text)
            console.log "added new file"
            @file_name_view.val(file.name)
            @file_contents_view.val(text)
            @updateListView(file.name)


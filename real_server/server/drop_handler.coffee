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
        @file_contents_view.val(window.file_store.getFile(file_name))
        @file_name_view.val(file_name)

    handleDrop: (event) =>
        droppedFiles = event.originalEvent.dataTransfer.files
        console.log "processing dropped files:" + droppedFiles
        for file in droppedFiles
            @handleFile(file)
            
    handleFile: (file) =>
        console.log "uploading" + file.name
        reader = new FileReader()
        reader.readAsText(file)  # Set the mode and the file
        reader.onload = (evt) =>
            console.log "reader loaded"
            text = evt.target.result  # Result of the text file.
            @file_store.addFile(file.name, text)
            console.log "added new file named " + file.name
            @updateListView(file.name)

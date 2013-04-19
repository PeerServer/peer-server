class window.DropHandler
    constructor: (@fileStore, @file_name_list, @file_name_view, @codeEditor) ->
        # Just setting up instance variables for now

    updateListView: (file_name) =>
        console.log "updating list view!!"
        console.log ' ' + @fileStore.fileNames()
        @file_name_list.empty()
        for idx,name of @fileStore.fileNames()
            console.log 'file:' + name
            @file_name_list.append('<option value="' + name + '">' + name + '</li>')
        @file_name_list.val(file_name)
        @codeEditor.setCodeContents(window.fileStore.getFileContents(file_name))
        @file_name_view.val(file_name)

    handleDrop: (event) =>
        droppedFiles = event.originalEvent.dataTransfer.files
        console.log "processing dropped files:" + droppedFiles
        for file in droppedFiles
            @handleFile(file)
            
    handleFile: (file) =>
        console.log "uploading" + file.name
        reader = new FileReader()
        if file.type is "image/jpeg"
            reader.readAsDataURL(file)
        else
            reader.readAsText(file)  # Set the mode and the file
        reader.onload = (evt) =>
            console.log "reader loaded"
            text = evt.target.result  # Result of the text file.
            @fileStore.addFile(file.name, file.size, file.type, text)
            console.log "added new file named " + file.name
            @updateListView(file.name)

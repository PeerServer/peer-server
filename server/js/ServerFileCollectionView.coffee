''' 
  Display and organization of the user-uploaded file collection. 
  Edit/Done modes for saving.
'''


class window.ServerFileCollectionView extends Backbone.View
  el: "#file-collection-view"

  initialize: (options) ->
    @previousServerFileView = null

    @fileViewContainer = @$("#file-view-container")
    @uploadFilesRegion = @$(".file-drop")
    @saveChangesButton = @$(".save-changes")
    @tmplFileListItem = Handlebars.compile($("#file-list-item-template").html())
    @tmplEditableFileListItem = Handlebars.compile($("#editable-file-list-item-template").html())

    @addAll()
    @collection.bind("add", @addOne)
    @collection.bind("reset", @addAll)
    @collection.bind("change", @handleFileChanged)

  events:
    "dragover .file-drop": "preventDefault"
    "drop .file-drop": "eventDropFiles"
    
    "click .file-list li[data-cid] input": "preventDefault"
    "blur .file-list li[data-cid] input": "eventDoneNamingFile"
    "keypress .file-list li[data-cid] input": "eventKeypressWhileRenaming"
    
    "click .file-list li[data-cid]": "eventSelectFile"
    "dblclick .file-list li[data-cid]": "eventDoubleClickFile"
    
    "click .save-changes": "eventSaveChanges"
    "click .upload-files": "eventUploadFiles"

    "click .create-menu .html": "eventCreateHTML"
    "click .create-menu .js": "eventCreateJS"
    "click .create-menu .css": "eventCreateCSS"
    # "click .create-menu .dynamic": "eventCreateDynamic"
    # "click .create-menu .template": "eventCreateTemplate"

  addAll: =>
    @collection.each(@addOne)

  addOne: (serverFile) =>
    return if serverFile.get("isProductionVersion")
    listEl = @tmplFileListItem(cid: serverFile.cid, name:serverFile.get("name"))
    @appendItemToFileList(serverFile, listEl)

  eventSelectFile: (event) =>
    target = $(event.currentTarget)
    cid = target.attr("data-cid")
    serverFile = @collection.get(cid)

    @uploadFilesRegion.hide()
    @fileViewContainer.show()

    @selectFile(serverFile, target)

    return false

  eventDoubleClickFile: (event) =>
    target = $(event.currentTarget)
    serverFile = @collection.get(target.attr("data-cid"))
    return if serverFile.get("isRequired")
    @editableFileName(serverFile, target)

  eventSaveChanges: =>
    @collection.createProductionVersion()
    @saveChangesButton.addClass("disabled")
    @saveChangesButton.find("a").text("Changes Saved")

  preventDefault: (event) =>
    event.preventDefault()
    return false

  eventUploadFiles: =>
    @$(".file-list li").removeClass("active")
    @fileViewContainer.hide()
    @uploadFilesRegion.show()

  eventDropFiles: (event) =>
    # Prevent the page from opening the file directly on drop.
    event.preventDefault()
    
    droppedFiles = event.originalEvent.dataTransfer.files
    for file in droppedFiles
      @handleFile(file)
      
    return false

  handleFile: (file) =>
    reader = new FileReader()
    fileType = ServerFile.prototype.rawTypeToFileType(file.type)
    if fileType is ServerFile.prototype.fileTypeEnum.IMG
      reader.readAsDataURL(file)
    else
      reader.readAsText(file)

    reader.onload = (evt) =>
      contents = evt.target.result  # Result of the text file.
      serverFile = new ServerFile(name: file.name, size: file.size, type: file.type, contents: contents)
      @collection.add(serverFile)
      serverFile.save()

  handleFileChanged: =>
    @saveChangesButton.removeClass("disabled")
    @saveChangesButton.find("a").text("Save Changes")

  # --- CREATION METHODS ---
  
  eventCreateHTML: =>
    serverFile = new ServerFile(type: "text/html")
    @createFile(serverFile)

  eventCreateJS: =>
    serverFile = new ServerFile(type: "application/x-javascript")
    @createFile(serverFile)

  eventCreateCSS: =>
    serverFile = new ServerFile(type: "text/css")
    @createFile(serverFile)

  createFile: (serverFile) =>
    @collection.add(serverFile, silent: true)
    @editableFileName(serverFile, null)

  # --- EDITING METHODS ---

  eventDoneNamingFile: (event) =>
    target = $(event.currentTarget)
    listEl = target.parents("li[data-cid]")

    serverFile = @collection.get(listEl.attr("data-cid"))
    # TODO validate name
    serverFile.save(name: target.val())
    
    newListEl = @tmplFileListItem(cid: serverFile.cid, name:serverFile.get("name"))
    newListEl = $($.parseHTML(newListEl))
    listEl.replaceWith(newListEl)
    @selectFile(serverFile, newListEl)

  eventKeypressWhileRenaming: (event) =>
    if event.keyCode is 13
      @eventDoneNamingFile(event)

  editableFileName: (serverFile, listElToReplace) =>
    listEl = @tmplEditableFileListItem(cid: serverFile.cid, name:serverFile.get("name"))
    if listElToReplace
      listEl = $($.parseHTML(listEl))
      listElToReplace.replaceWith(listEl)
    else
      listEl = @appendItemToFileList(serverFile, listEl)
    listEl.find("input").focus()

  # --- HELPER METHODS ---
  
  appendItemToFileList: (serverFile, listEl) =>
    section = null
    if serverFile.get("isRequired")
      section = @$(".file-list.required")
    else
      switch serverFile.get("fileType")
        when ServerFile.prototype.fileTypeEnum.HTML then section = @$(".file-list.html")
        when ServerFile.prototype.fileTypeEnum.CSS  then section = @$(".file-list.css")
        when ServerFile.prototype.fileTypeEnum.JS   then section = @$(".file-list.js")
        when ServerFile.prototype.fileTypeEnum.IMG  then section = @$(".file-list.img")

    if section
      return section.append(listEl)
    return null

  selectFile: (serverFile, listEl) =>
    @$(".file-list li").removeClass("active")
    listEl.addClass("active")

    @previousServerFileView.remove() if @previousServerFileView
    serverFileView = new ServerFileView(model: serverFile)
    @fileViewContainer.append(serverFileView.render().el)
    @previousServerFileView = serverFileView

    @fileViewContainer.height($(window).height() - @fileViewContainer.offset().top)


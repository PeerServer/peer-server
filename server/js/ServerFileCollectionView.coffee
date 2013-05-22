'''
  Display and organization of the user-uploaded file collection.
  Edit/Done modes for saving.
'''


class window.ServerFileCollectionView extends Backbone.View
  el: "#file-collection-view"

  initialize: (options) ->
    @activeServerFileView = null

    @fileViewContainer = @$("#file-view-container")
    @uploadFilesRegion = @$(".file-drop")
    @fileLists = @$(".file-list")
    @saveChangesButton = @$(".save-changes")
    @tmplFileListItem = Handlebars.compile($("#file-list-item-template").html())
    @tmplFileDeleteConfirmation = Handlebars.compile(
      $("#file-delete-confirmation-template").html())
    @tmplEditableFileListItem = Handlebars.compile(
      $("#editable-file-list-item-template").html())

    @addAll()
    @collection.bind("add", @addOne)
    @collection.bind("reset", @addAll)
    @collection.bind("change", @handleFileChanged)
    @collection.bind("destroy", @handleFileDeleted)

    $(window).keydown(@eventKeyDown)

  events:
    "dragover .file-drop": "preventDefault"
    "drop .file-drop": "eventDropFiles"
    
    "click .file-list li[data-cid] input": "preventDefault"
    "blur .file-list li[data-cid] input": "eventDoneNamingFile"
    "keypress .file-list li[data-cid] input": "eventKeypressWhileRenaming"
    
    "click .file-list li[data-cid]": "eventSelectFile"
    "click .file-list li[data-cid] .dropdown-menu .rename": "eventRenameFile"
    "click .file-list li[data-cid] .dropdown-menu .delete": "eventDeleteFile"
    "click .file-delete-confirmation .deletion-confirmed": "eventDeleteFileConfirmed"
    
    "click .save-changes": "eventSaveChanges"
    "click .upload-files": "eventUploadFiles"

    "click .create-menu .html": "eventCreateHTML"
    "click .create-menu .js": "eventCreateJS"
    "click .create-menu .css": "eventCreateCSS"
    "click .create-menu .dynamic": "eventCreateDynamic"
    # TODO "click .create-menu .template": "eventCreateTemplate"
    
  addAll: =>
    @collection.each(@addOne)

  addOne: (serverFile) =>
    return if serverFile.get("isProductionVersion")
    listEl = @tmplFileListItem(
      cid: serverFile.cid,
      name: serverFile.get("name"),
      isRequired: serverFile.get("isRequired"))
    @appendItemToFileList(serverFile, listEl)

  eventSelectFile: (event) =>
    target = $(event.currentTarget)
    cid = target.attr("data-cid")
    serverFile = @collection.get(cid)

    if @activeServerFileView and @activeServerFileView.model is serverFile
      target.find(".dropdown-menu").removeAttr("style")
      target.addClass("open")
    else
      @fileLists.find(".dropdown-menu").hide()
      @fileLists.find(".caret").hide()

      @uploadFilesRegion.hide()
      @fileViewContainer.show()

      @selectFile(serverFile, target)

    return false

  eventRenameFile: (event) =>
    target = $(event.currentTarget).parents("li[data-cid]")
    serverFile = @collection.get(target.attr("data-cid"))
    @editableFileName(serverFile, target)

  eventDeleteFile: (event) =>
    target = $(event.currentTarget).parents("li[data-cid]")
    serverFile = @collection.get(target.attr("data-cid"))
    
    modal = @tmplFileDeleteConfirmation(
      cid: serverFile.cid, name: serverFile.get("name"))
    modal = $($.parseHTML(modal))
    modal.appendTo(@el)

    modal.modal(backdrop: true, show:true)
    
    modal.on "hide", () ->
      modal.data("modal", null)
      modal.remove()
      $(".modal-backdrop").remove()

  eventDeleteFileConfirmed: (event) =>
    target = $(event.currentTarget)
      .parents(".file-delete-confirmation[data-cid]")
    target.modal("hide")
    serverFile = @collection.get(target.attr("data-cid"))
    serverFile.destroy()
    @activeServerFileView.remove() if @activeServerFileView
    @activeServerFileView = null

  eventKeyDown: (event) =>
    # This condition evaluates to true if CTRL-s or CMD-s are pressed.
    # (83 is the keyCode for "s")
    if event.which is 83 and (event.ctrlKey or event.metaKey)
      @eventSaveChanges()
      return false

  eventSaveChanges: =>
    @collection.createProductionVersion()
    @saveChangesButton.addClass("disabled")
    @saveChangesButton.find("a").text("Changes Saved")

  preventDefault: (event) =>
    event.preventDefault()
    return false

  eventUploadFiles: =>
    @activeServerFileView.remove() if @activeServerFileView
    @activeServerFileView = null
    @fileLists.find(".dropdown-menu").hide()
    @fileLists.find(".caret").hide()
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
    fileType = ServerFile.rawTypeToFileType(file.type)
    if fileType is ServerFile.fileTypeEnum.IMG
      reader.readAsDataURL(file)
    else
      reader.readAsText(file)

    reader.onload = (evt) =>
      contents = evt.target.result  # Result of the text file.
      serverFile = new ServerFile(
        name: file.name, size: file.size, type: file.type, contents: contents)
      @collection.add(serverFile)
      serverFile.save()

  handleFileChanged: =>
    @saveChangesButton.removeClass("disabled")
    @saveChangesButton.find("a").text("Save Changes")

  handleFileDeleted: (deletedServerFile) =>
    @$("[data-cid=#{deletedServerFile.cid}]").remove()

  # --- CREATION METHODS ---
  
  eventCreateHTML: =>
    serverFile = new ServerFile(type: "text/html")
    @createFile(serverFile)

  eventCreateJS: =>
    serverFile = new ServerFile(type: "application/x-javascript")
    @createFile(serverFile)
  
  eventCreateDynamic: =>
    serverFile = new ServerFile(type: "application/dynamic")
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
    
    newListEl = @tmplFileListItem(
      cid: serverFile.cid,
      name: serverFile.get("name"),
      isRequired: serverFile.get("isRequired"))
    newListEl = $($.parseHTML(newListEl))
    listEl.replaceWith(newListEl)
    @selectFile(serverFile, newListEl)

  eventKeypressWhileRenaming: (event) =>
    if event.keyCode is 13
      @eventDoneNamingFile(event)

  editableFileName: (serverFile, listElToReplace) =>
    listEl = @tmplEditableFileListItem(
      cid: serverFile.cid, name:serverFile.get("name"))
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
        when ServerFile.fileTypeEnum.HTML     then section = @$(".file-list.html")
        when ServerFile.fileTypeEnum.CSS      then section = @$(".file-list.css")
        when ServerFile.fileTypeEnum.JS       then section = @$(".file-list.js")
        when ServerFile.fileTypeEnum.IMG      then section = @$(".file-list.img")
        when ServerFile.fileTypeEnum.DYNAMIC  then section = @$(".file-list.dynamic")

    if section
      return section.append(listEl)
    return null

  selectFile: (serverFile, listEl) =>
    @$(".file-list li").removeClass("active")
    listEl.addClass("active")

    caret = listEl.find(".caret")
    caret.show()

    @activeServerFileView.remove() if @activeServerFileView
    serverFileView = new ServerFileView(model: serverFile)
    @fileViewContainer.append(serverFileView.render().el)
    @activeServerFileView = serverFileView

    @fileViewContainer.height(
      $(window).height() - @fileViewContainer.offset().top)


''' 
  Display and organization of the user-uploaded file collection. 
  Edit/Done modes for saving.
'''


class window.ServerFileCollectionView extends Backbone.View
  el: "#file-collection-view"

  initialize: (options) ->
    @isEditable = options.isEditable
    @previousServerFileView = null

    @tmplFileListItem = Handlebars.compile($("#file-list-item-template").html())
    @render()

    @addAll()
    @collection.bind("add", @addOne)
    @collection.bind("reset", @addAll)

  events:
    "dragover .file-drop": "preventDefault"
    "drop .file-drop": "eventDropFiles"
    "click .file-list li[data-cid]": "eventSelectFile"

  toggleIsEditable: =>
    @isEditable = !@isEditable
    @render()

  render: =>
    if @isEditable
      @switchToEditableMode()
    else
      @switchToReadOnlyMode()

  addAll: =>
    @collection.each(@addOne)

  addOne: (serverFile) =>
    return if serverFile.get("isProductionVersion")
    @appendFileToFileList(serverFile)

  eventSelectFile: (event) =>
    target = $(event.currentTarget)
    @$(".file-list li").removeClass("active")
    target.addClass("active")
    cid = target.attr("data-cid")
    serverFile = @collection.get(cid)

    @previousServerFileView.remove() if @previousServerFileView
    serverFileView = new ServerFileView(model: serverFile, isEditable: @isEditable)
    @$("#file-view-container").append(serverFileView.render().el)
    @previousServerFileView = serverFileView

    return false

  preventDefault: (event) =>
    event.preventDefault()



  # --- READ-ONLY MODE METHODS ---
  
  switchToReadOnlyMode: =>
    @$(".file-drop").hide()
    if @previousServerFileView
      @previousServerFileView.setIsEditable(false)
    
  # --- EDIT MODE METHODS ---

  switchToEditableMode: =>
    @$(".file-drop").show()
    if @previousServerFileView
      @previousServerFileView.setIsEditable(true)

  eventDropFiles: (event) =>
    return unless @isEditable
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

  # --- HELPER METHODS ---
  
  appendFileToFileList: (serverFile) =>
    listEl = @tmplFileListItem(cid: serverFile.cid, name:serverFile.get("name"))

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
      section.append(listEl)


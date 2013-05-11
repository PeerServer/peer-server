''' 
  Display and organization of the user-uploaded file collection. 
  Edit/Done modes for saving.
'''


class window.ServerFileCollectionView extends Backbone.View
  el: "#file-collection-view"

  initialize: (options) ->
    @isEditable = options.isEditable
    @previousServerFileView = null

    @render()

    @collection.bind("add", @addOne)
    @collection.bind("reset", @addAll)
    @collection.fetch()

  events:
    "dragover .file-drop": "preventDefault"
    "drop .file-drop": "eventDropFiles"
    "click .file-list li[data-cid]": "eventSelectFile"
    "change .landing-page": "eventChangeLandingPage"

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

    listEl = $("<li data-cid='#{serverFile.cid}'><a href='#'>#{serverFile.get('name')}</a></li>")

    headerToAppendAfter = null
    switch serverFile.get("fileType")
      when ServerFile.prototype.fileTypeEnum.HTML then headerToAppendAfter = @$(".nav-header.html")
      when ServerFile.prototype.fileTypeEnum.CSS  then headerToAppendAfter = @$(".nav-header.css")
      when ServerFile.prototype.fileTypeEnum.JS   then headerToAppendAfter = @$(".nav-header.js")
      when ServerFile.prototype.fileTypeEnum.IMG  then headerToAppendAfter = @$(".nav-header.img")

    if headerToAppendAfter
      nextHeader = headerToAppendAfter.nextAll(".nav-header").first()
    else
      nextHeader = null

    if nextHeader and nextHeader.length > 0
      nextHeader.before(listEl)
    else
      @$(".file-list").append(listEl)

    @addedServerFile(serverFile)

  addedServerFile: (serverFile) =>
    if serverFile.get("fileType") is ServerFile.prototype.fileTypeEnum.HTML
      optionEl = $("<option value='#{serverFile.cid}'>#{serverFile.get('name')}</option>")
      if serverFile.get("isLandingPage")
        optionEl.attr("selected", "selected")
      @$(".landing-page").append(optionEl)

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
    @$(".landing-page").attr("disabled", "disabled")
    if @previousServerFileView
      @previousServerFileView.setIsEditable(false)
    
  # --- EDIT MODE METHODS ---

  switchToEditableMode: =>
    @$(".file-drop").show()
    @$(".landing-page").removeAttr("disabled")
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

  eventChangeLandingPage: (event) =>
    return unless @isEditable
    @collection.forEachDevelopmentFile (serverFile) ->
      serverFile.save("isLandingPage", false)

    target = $(event.currentTarget)
    cid = target.val()
    serverFile = @collection.get(cid)
    serverFile.save("isLandingPage", true)


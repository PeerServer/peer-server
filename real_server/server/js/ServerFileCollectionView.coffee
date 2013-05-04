class window.ServerFileCollectionView extends Backbone.View
  el: "#file-collection-view"

  initialize: ->
    @collection = new ServerFileCollection()
    @collection.bind("add", @appendServerFile)
    @collection.bind("change", @isLandingPageChanged)

    @fileStore = window.fileStore
    @fileStore.registerForEvent("fileStore:fileAdded", @handleFileAdded)

    @previousServerFileView = null
    @initFromFileStore()

  initFromFileStore: =>
    filenames = @fileStore.fileNames()
    for filename in filenames
      fileEntry = @fileStore.getFileEntry(filename)
      serverFile = new ServerFile(fileEntry)
      @collection.add(serverFile)

  getLandingPage: ->
    landing = @collection.find (serverFile) ->
      return serverFile.get("isLandingPage")

    if landing
      path = landing.get("name")
      contents = window.fileStore.getFileContents(path)
      return {"fileContents": contents, "filename": path, "type": "text/html"}
    else
      return {"fileContents": "no landing page", "filename": "404.html", "type": "text/html"}

  isLandingPageChanged: (serverFile) =>
    if serverFile.get("isLandingPage")
      @$("option.#{serverFile.cid}").attr("selected", "selected")
    else
      @$("option.#{serverFile.cid}").removeAttr("selected")

  handleFileAdded: (data) =>
    return if @collection.findWhere(name: data.name)
    fileEntry = @fileStore.getFileEntry(data.name)
    serverFile = new ServerFile(fileEntry)
    @collection.add(serverFile)

  handleDrop: (event) =>
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
      @fileStore.addFile(file.name, file.size, file.type, contents)

  handleFileSelection: (event) =>
    target = $(event.currentTarget)
    @$(".file-list li").removeClass("active")
    target.addClass("active")
    cid = target.attr("data-cid")
    serverFile = @collection.get(cid)

    @previousServerFileView.remove() if @previousServerFileView
    serverFileView = new ServerFileView(model: serverFile)
    @.$("#file-view-container").append(serverFileView.render().el)
    @previousServerFileView = serverFileView

    return false

  preventDefault: (event) =>
    event.preventDefault()

  handleLandingPageChange: (event) =>
    @collection.each (serverFile) ->
      serverFile.set("isLandingPage", false)

    target = $(event.currentTarget)
    cid = target.val()
    serverFile = @collection.get(cid)
    serverFile.set("isLandingPage", true)

  appendServerFile: (serverFile) =>
    if serverFile.get("fileType") is ServerFile.prototype.fileTypeEnum.HTML
      optionEl = $("<option value='#{serverFile.cid}'>#{serverFile.get('name')}</option>")
      if serverFile.get("isLandingPage")
        optionEl.attr("selected", "selected")
      @$(".landing-page").append(optionEl)
    
    listEl = $("<li data-cid='#{serverFile.cid}'><a href='#'>#{serverFile.get('name')}</a></li>")

    headerToAppendAfter = null
    switch serverFile.get("fileType")
      when ServerFile.prototype.fileTypeEnum.HTML then headerToAppendAfter = @$(".html")
      when ServerFile.prototype.fileTypeEnum.CSS  then headerToAppendAfter = @$(".css")
      when ServerFile.prototype.fileTypeEnum.JS   then headerToAppendAfter = @$(".js")
      when ServerFile.prototype.fileTypeEnum.IMG  then headerToAppendAfter = @$(".img")

    nextHeader = headerToAppendAfter.nextAll(".nav-header").first()
    if nextHeader.length > 0
      nextHeader.before(listEl)
     else
       @$(".file-list").append(listEl)

  events:
    "dragover .file-drop": "preventDefault"
    "drop .file-drop": "handleDrop"
    "click .file-list li[data-cid]": "handleFileSelection"
    "change .landing-page": "handleLandingPageChange"



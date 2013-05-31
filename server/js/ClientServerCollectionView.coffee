'''
  Display and organization of the user-uploaded file collection.
  Edit/Done modes for saving.

  TODO handle bug of initial non-index, non-404 html files saved in localstorage returining a 404
    due to there being no initial production version of them formed.
'''


class window.ClientServerCollectionView extends Backbone.View
  el: "#client-server-collection-view"

  initialize: (options) ->
    @serverFileCollection = options.serverFileCollection
    @routeCollection = options.routeCollection
    @userDatabase = options.userDatabase

    @activeView = null

    @fileViewContainer = @$("#file-view-container")
    @routeViewContainer = @$("#route-view-container")
    @uploadFilesRegion = @$(".file-drop")
    @saveNotification = $("#save-notification").miniNotification(show: false)

    @fileLists = @$(".file-list")
    @requiredFileList = @$(".file-list.required")
    @htmlFileList = @$(".file-list.html")
    @cssFileList = @$(".file-list.css")
    @jsFileList = @$(".file-list.js")
    @imageFileList = @$(".file-list.img")
    @dynamicFileList = @$(".file-list.dynamic")

    @tmplServerFileListItem = Handlebars.templates["file-list-item"]
    @tmplRouteListItem = Handlebars.templates["route-list-item"]
    @tmplFileDeleteConfirmation = Handlebars.templates["file-delete-confirmation"]
    @tmplEditableFileListItem = Handlebars.templates["editable-file-list-item"]

    @addAll()
    
    @serverFileCollection.bind("add", @addOneServerFile)
    @serverFileCollection.bind("reset", @addAll)
    @serverFileCollection.bind("change:contents", @handleFileChanged)
    @serverFileCollection.bind("destroy", @handleFileDeleted)

    @routeCollection.bind("add", @addOneRoute)
    @routeCollection.bind("reset", @addAll)
    @routeCollection.bind("change:routePath", @handleFileChanged)
    @routeCollection.bind("change:routeCode", @handleFileChanged)
    @routeCollection.bind("change:name", @handleFileChanged)
    @routeCollection.bind("change:name", @handleRouteNameChange)
    @routeCollection.bind("destroy", @handleFileDeleted)

    $(window).keydown(@eventKeyDown)
    $(window).resize(@render)

    @render()
    @showInitialSaveNotification()

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
    
    "click .upload-files": "eventUploadFiles"
    "click .save-changes": "eventSaveChanges"

    "click .create-menu .html": "eventCreateHTML"
    "click .create-menu .js": "eventCreateJS"
    "click .create-menu .css": "eventCreateCSS"
    "click .create-menu .dynamic": "eventCreateDynamic"
    # TODO "click .create-menu .template": "eventCreateTemplate"

  render: =>
    @mainPane = @$(".main-pane")
    @$(".left-sidebar-container").outerHeight($(window).height())
    @$(".left-sidebar").outerHeight($(window).height())
    @mainPane.height($(window).height() - @mainPane.position().top)
    @mainPane.width($(window).width() - @mainPane.position().left)

    @routeViewContainer.hide()
    @fileViewContainer.hide()
    @uploadFilesRegion.show()

  showInitialSaveNotification: =>
    shouldShow = false

    @serverFileCollection.forEachDevelopmentFile (devFile) ->
      if devFile.get("hasBeenEdited")
        shouldShow = true

    @routeCollection.each (route) ->
      if not route.get("isProductionVersion") and route.get("hasBeenEdited")
        shouldShow = true

    if shouldShow
      @saveNotification.show()
    
  addAll: =>
    @serverFileCollection.each(@addOneServerFile)
    @routeCollection.each(@addOneRoute)

  addOneServerFile: (serverFile) =>
    return if serverFile.get("isProductionVersion")
    listEl = @tmplServerFileListItem(
      cid: serverFile.cid,
      name: serverFile.get("name"),
      isRequired: serverFile.get("isRequired"))
    @appendServerFileToFileList(serverFile, listEl)

  addOneRoute: (route) =>
    return if route.get("isProductionVersion")
    listEl = @tmplRouteListItem(cid: route.cid, name: route.get("name"))
    @dynamicFileList.append(listEl)

  eventSelectFile: (event) =>
    target = $(event.currentTarget)
    cid = target.attr("data-cid")

    serverFile = @serverFileCollection.get(cid)
    route = @routeCollection.get(cid)
    resource = serverFile or route
    if resource
      if @activeView and @activeView.model is resource
        target.find(".dropdown-menu").removeAttr("style")
        target.addClass("open")
      else
        @fileLists.find(".dropdown-menu").hide()
        @fileLists.find(".caret").hide()

        @uploadFilesRegion.hide()
        @routeViewContainer.hide()
        @fileViewContainer.hide()

        if serverFile
          @selectServerFile(serverFile, target)
        else if route
          @selectRoute(route, target)

    return false

  eventRenameFile: (event) =>
    target = $(event.currentTarget).parents("li[data-cid]")
    serverFile = @serverFileCollection.get(target.attr("data-cid"))
    @editableFileName(serverFile, target)

  eventDeleteFile: (event) =>
    target = $(event.currentTarget).parents("li[data-cid]")
    serverFile = @serverFileCollection.get(target.attr("data-cid"))
    route = @routeCollection.get(target.attr("data-cid"))
    resource = serverFile or route
    
    modal = @tmplFileDeleteConfirmation(
      cid: resource.cid, name: resource.get("name"))
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

    serverFile = @serverFileCollection.get(target.attr("data-cid"))
    route = @routeCollection.get(target.attr("data-cid"))
    resource = serverFile or route
    resource.destroy()

    @activeView.remove() if @activeView
    @activeView = null

  eventKeyDown: (event) =>
    # This condition evaluates to true if CTRL-s or CMD-s are pressed.
    # (83 is the keyCode for "s")
    if event.which is 83 and (event.ctrlKey or event.metaKey)
      @eventSaveChanges()
      return false

  eventSaveChanges: =>
    @serverFileCollection.forEachDevelopmentFile (devFile) ->
      devFile.save(hasBeenEdited: false)

    @routeCollection.each (route) ->
      route.save(hasBeenEdited: false)

    @saveNotification.hide()
    @serverFileCollection.createProductionVersion()
    @routeCollection.createProductionVersion()

  preventDefault: (event) =>
    event.preventDefault()
    return false

  eventUploadFiles: =>
    @activeView.remove() if @activeView
    @activeView = null
    @fileLists.find(".dropdown-menu").hide()
    @fileLists.find(".caret").hide()
    @$(".file-list li").removeClass("active")
    @fileViewContainer.hide()
    @routeViewContainer.hide()
    @uploadFilesRegion.show()

  eventDropFiles: (event) =>
    # Prevent the page from opening the file directly on drop.
    event.preventDefault()
    
    droppedFiles = event.originalEvent.dataTransfer.files
    for file in droppedFiles
      @handleFile(file)
      
    return false

  handleFile: (file) =>
    if file.type is "application/zip"
      @handleZipFile(file)
      return

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
      @serverFileCollection.add(serverFile)
      serverFile.save()

  handleZipFile: (file) =>
    reader = new FileReader()
    reader.readAsArrayBuffer(file)
    reader.onload = (evt) =>
      new ClientServerUnarchiver(
        serverFileCollection: @serverFileCollection,
        routeCollection: @routeCollection,
        userDatabase: @userDatabase,
        contents: evt.target.result)

  handleFileChanged: (model) =>
    model.save(hasBeenEdited: true)
    @saveNotification.show()

  handleRouteNameChange: (route) =>
    @$("li[data-cid=#{route.cid}] > a").text(route.get("name"))

  handleFileDeleted: (model) =>
    @$("[data-cid=#{model.cid}]").remove()

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
    @serverFileCollection.add(serverFile, silent: true)
    @editableFileName(serverFile, null)

  eventCreateDynamic: =>
    route = new Route()
    @routeCollection.add(route)
    route.save()
    listEl = @$("li[data-cid=#{route.cid}]")
    @selectRoute(route, listEl)

  # --- EDITING METHODS ---

  eventDoneNamingFile: (event) =>
    target = $(event.currentTarget)
    listEl = target.parents("li[data-cid]")

    serverFile = @serverFileCollection.get(listEl.attr("data-cid"))
    # TODO validate name
    serverFile.save(name: target.val())
    
    newListEl = @tmplServerFileListItem(
      cid: serverFile.cid,
      name: serverFile.get("name"),
      isRequired: serverFile.get("isRequired"))
    newListEl = $($.parseHTML(newListEl))
    listEl.replaceWith(newListEl)
    @selectServerFile(serverFile, newListEl)

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
      listEl = @appendServerFileToFileList(serverFile, listEl)
    listEl.find("input").focus()

  # --- HELPER METHODS ---
  
  appendServerFileToFileList: (serverFile, listEl) =>
    section = null
    if serverFile.get("isRequired")
      section = @requiredFileList
    else
      switch serverFile.get("fileType")
        when ServerFile.fileTypeEnum.HTML then section = @htmlFileList
        when ServerFile.fileTypeEnum.CSS  then section = @cssFileList
        when ServerFile.fileTypeEnum.JS   then section = @jsFileList
        when ServerFile.fileTypeEnum.IMG  then section = @imageFileList
        else                              console.error("Error: Could not find proper place for file. " + serverFile.get("name"))
    if section
      return section.append(listEl)
    return null

  select: (listEl, view) =>
    @$(".file-list li").removeClass("active")
    listEl.addClass("active")
    listEl.find(".caret").show()

    @activeView.remove() if @activeView
    @activeView = view

  selectServerFile: (serverFile, listEl) =>
    serverFileView = new ServerFileView(model: serverFile)
    @select(listEl, serverFileView)
    @fileViewContainer.append(serverFileView.render().el)
    @fileViewContainer.show()

  selectRoute: (route, listEl) =>
    productionRoute = @routeCollection.findWhere(name: route.get("name"), isProductionVersion: true)
    routeView = new RouteView(model: route, productionRoute: productionRoute)
    @select(listEl, routeView)
    @routeViewContainer.append(routeView.render().el)
    @routeViewContainer.show()
    routeView.adjustHeights()
    routeView.focus()


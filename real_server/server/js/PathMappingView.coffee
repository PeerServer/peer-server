class window.PathMappingView extends Backbone.View
  className: "tab-pane active"
  
  initialize: ->
    _.bindAll @

    @fileStore = window.fileStore
    @fileStore.registerForEvent("fileStore:fileAdded", @handleFileAdded)
    
    @model.bind("change:isLandingPage", @handleIsLandingPageChange)

    
  render: =>
    @el.id = @model.cid
    template = Handlebars.compile($("#tab-pane-template").html())
    $(@el).html(template)
    
    @landingPageButton = $(@el).find(".landing-page")
    if @model.get("isLandingPage")
      @landingPageButton.addClass("active")
    else
      @landingPageButton.removeClass("active")
    
    @elFileList = $(@el).find(".file-list")

    fileContents = $(@el).find(".file-contents")
    fileContents.text("<!-- Code goes here -->")
    @aceEditor = ace.edit(fileContents[0])
    @aceEditor.setTheme("ace/theme/tomorrow_night_eighties")
    @aceEditor.getSession().setMode("ace/mode/html")
    @aceEditor.setFontSize("12px")
    
    return @

  handleDrop: (event) ->
    # Prevent the page from opening the file directly on drop.
    event.preventDefault()
    
    droppedFiles = event.originalEvent.dataTransfer.files
    console.log "processing dropped files:" + droppedFiles
    for file in droppedFiles
      @handleFile(file)
      
    return false

  handleFile: (file) ->
    console.log "uploading" + file.name
    reader = new FileReader()
    if file.type is "image/jpeg"
      reader.readAsDataURL(file)
    else
      reader.readAsText(file)  # Set the mode and the file
    reader.onload = (evt) =>
      text = evt.target.result  # Result of the text file.
      @fileStore.addFile(file.name, file.size, file.type, text)
      console.log "added new file named " + file.name + file.size
#      window.ServerUserPortal.updateFileListView(file.name)

  handleFileAdded: (data) ->
    return if $(@el).is(':hidden')
    
    filename = data.name
    if filename.slice(-5) is ".html"
      @model.set("path", filename)
    @elFileList.append("<li><a href='#'>#{filename}</a></li>")
    @aceEditor.setValue(window.fileStore.getFileContents(filename))
    @aceEditor.navigateFileStart()

  handleFileSelection: (event) ->
    target = $(event.target)
    filename = target.text() # TODO: BAD!
    @aceEditor.setValue(window.fileStore.getFileContents(filename))
    @aceEditor.navigateFileStart()
    
  preventDefault: (event) ->
    event.preventDefault()

  handleLandingPage: () ->
    isLandingPage = not @landingPageButton.hasClass("active")
    if isLandingPage != @model.get("isLandingPage")
      @model.set("isLandingPage", isLandingPage)

  handleIsLandingPageChange: ->
    console.log "change"
    if @model.get("isLandingPage")
      @landingPageButton.addClass("active")
    else
      @landingPageButton.removeClass("active")
    
  events:
    "dragover .file-drop": "preventDefault"
    "drop .file-drop": "handleDrop"
    "click .file-list li": "handleFileSelection"
    "click .landing-page": "handleLandingPage"

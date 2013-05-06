class window.ServerFileView extends Backbone.View

  initialize: (options) ->
    @isEditable = options.isEditable

  render: =>
    if @model.get("fileType") isnt ServerFile.prototype.fileTypeEnum.IMG
      @renderAsSourceCode()
    else
      @renderAsImage()
    return @

  renderAsSourceCode: =>
    template = Handlebars.compile($("#source-code-template").html())
    $(@el).html(template)
    
    # Set up ACE editor
    fileContents = $(@el).find(".file-contents")
    fileContents.text(@model.get("contents"))
    @aceEditor = ace.edit(fileContents[0])
    @aceEditor.setTheme("ace/theme/tomorrow_night_eighties")
    @aceEditor.setFontSize("12px")

    editorMode = "ace/mode/html" # Default to HTML
    switch @model.get("fileType")
      when ServerFile.prototype.fileTypeEnum.CSS  then editorMode = "ace/mode/css"
      when ServerFile.prototype.fileTypeEnum.JS   then editorMode = "ace/mode/javascript"
    @aceEditor.getSession().setMode(editorMode)

    if @isEditable
      @renderAsSourceCodeEditable()
    else
      @renderAsSourceCodeReadOnly()

  renderAsSourceCodeEditable: =>
      @aceEditor.on("change", @updateContents)

  renderAsSourceCodeReadOnly: =>
      @aceEditor.setReadOnly(true)

  renderAsImage: =>
    template = Handlebars.compile($("#image-template").html())
    $(@el).html(template)
    @$("img").attr("src", @model.get("contents"))

  updateContents: =>
    @model.save("contents", @aceEditor.getValue())

  setIsEditable: (isEditable) =>
    return if @isEditable is isEditable
    @isEditable = isEditable
    @render()


'''
  View of a single file in the editor (depends on js/img/css etc)
'''

class window.ServerFileView extends Backbone.View

  initialize: (options) ->
    @tplSourceCode = Handlebars.templates["source-code"]
    @tplImage = Handlebars.templates["image"]

    @model.on("destroy", @onDestroy)

  events:
    "remove": "onDestroy"

  render: =>
    if @model.get("fileType") isnt ServerFile.fileTypeEnum.IMG
      @renderAsSourceCode()
    else
      @renderAsImage()
    return @

  renderAsSourceCode: =>
    $(@el).html(@tplSourceCode)
    
    # Set up ACE editor
    fileContents = $(@el).find(".file-contents")
    fileContents.text(@model.get("contents"))
    @aceEditor = ace.edit(fileContents[0])
    @aceEditor.setTheme("ace/theme/tomorrow_night_eighties")
    @aceEditor.setFontSize("12px")

    editorMode = "ace/mode/html" # Default to HTML
    switch @model.get("fileType")
      when ServerFile.fileTypeEnum.CSS then editorMode = "ace/mode/css"
      when ServerFile.fileTypeEnum.JS then editorMode = "ace/mode/javascript"
    @aceEditor.getSession().setMode(editorMode)

    @aceEditor.on("change", @updateContents)

  renderAsImage: =>
    $(@el).html(@tplImage)
    @$("img").attr("src", @model.get("contents"))

  updateContents: =>
    @model.save("contents", @aceEditor.getValue())

  onDestroy: =>
    if @model.get("fileType") isnt ServerFile.fileTypeEnum.IMG
      @aceEditor.destroy()

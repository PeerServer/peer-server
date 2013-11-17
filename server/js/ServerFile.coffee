class window.ServerFile extends Backbone.Model
  defaults:
    name: ""
    size: 0
    contents: ""
    type: ""
    fileType: ""
    isProductionVersion: false
    isRequired: false
    dateCreated: null
    hasBeenEdited: false

  # If these are updated, note that there are dependencies on the client-side
  # for rendering.
  @fileTypeEnum:
    HTML: "HTML",
    CSS: "CSS",
    JS: "JS",
    IMG: "IMG",
    TEMPLATE: "TEMPLATE",
    NONE: "NONE"

  @fileTypeToFileExt:
    HTML: "html",
    CSS: "css",
    JS: "js",
    TEMPLATE: "handlebars"

  @fileExtToFileType: _.invert(@fileTypeToFileExt)

  initialize: ->
    @on("change:type", @updateFileType)
    @updateFileType()

    if @get("dateCreated") is null
      @set("dateCreated", new Date())

  updateFileType: =>
    if @get("type")
      @set("fileType", ServerFile.rawTypeToFileType(@get("type")))
    else
      @set("fileType", ServerFile.filenameToFileType(@get("name")))

  @rawTypeToFileType: (rawType) =>
    if rawType.indexOf("image") != -1
      return ServerFile.fileTypeEnum.IMG
    if rawType.indexOf("html") != -1 or rawType is "text/plain"
      return ServerFile.fileTypeEnum.HTML
    if rawType.indexOf("css") != -1
      return ServerFile.fileTypeEnum.CSS
    if rawType.indexOf("handlebars") != -1
      return ServerFile.fileTypeEnum.TEMPLATE
    if rawType.indexOf("javascript") != -1
      return ServerFile.fileTypeEnum.JS
    console.error "Unable to identify file type: " + rawType

  @filenameToFileType: (filename) =>
    ext = filename.replace(/.*\.([a-z]+$)/i, "$1")
    switch ext
      when "html" then return ServerFile.fileTypeEnum.HTML
      when "jpg", "jpeg", "png" then return ServerFile.fileTypeEnum.IMG
      when "css" then return ServerFile.fileTypeEnum.CSS
      when "js" then return ServerFile.fileTypeEnum.JS
      when "handlebars" then return ServerFile.fileTypeEnum.TEMPLATE
      when "tmpl" then return ServerFile.fileTypeEnum.TEMPLATE
    console.error "Attempt to convert file name " + filename + " to file type failed, returning null."
    return null

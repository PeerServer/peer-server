class window.ServerFile extends Backbone.Model
  defaults:
    name: ""
    size: 0
    contents: ""
    type: ""
    fileType: ""
    isProductionVersion: false
    isRequired: false

  # TODO -- if these are updated to be static, note that there is a
  #  dependency on the client-side at least for images.
  @fileTypeEnum:
    HTML: "HTML",
    CSS: "CSS",
    JS: "JS",
    IMG: "IMG",
    DYNAMIC: "DYNAMIC",
    NONE: "NONE"

  initialize: ->
    @on("change:type", @updateFileType)
    @updateFileType()

  updateFileType: =>
    @set("fileType", ServerFile.rawTypeToFileType(@get("type")))

  @rawTypeToFileType: (rawType) =>
    if rawType in ["image/jpeg", "image/png"]
      return ServerFile.fileTypeEnum.IMG
    if rawType is "text/html"
      return ServerFile.fileTypeEnum.HTML
    if rawType is "text/css"
      return ServerFile.fileTypeEnum.CSS
    if rawType is "application/x-javascript"
      return ServerFile.fileTypeEnum.JS
    if rawType is "application/dynamic"
      # This is a new made-up mime type indicating javascript to be evaluated
      # on the server side
      return ServerFile.fileTypeEnum.DYNAMIC
    return ServerFile.fileTypeEnum.NONE

  # Files for which this evaluates to true should never be served in plain text
  isDynamic: =>
    return @get("type") is "application/dynamic"


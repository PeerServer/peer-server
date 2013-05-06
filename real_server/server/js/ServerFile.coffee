class window.ServerFile extends Backbone.Model
  defaults:
    name: ""
    size: 0
    contents: ""
    type: ""
    fileType: ""
    isLandingPage: false
    isProductionVersion: false

  fileTypeEnum:
    HTML: "HTML",
    CSS: "CSS",
    JS: "JS",
    IMG: "IMG",
    NONE: "NONE"

  initialize: () ->
    @on("change:type", @updateFileType)
    @updateFileType()

  updateFileType: =>
    @set("fileType", @rawTypeToFileType(@get("type")))

  rawTypeToFileType: (rawType) =>
    if rawType in ["image/jpeg", "image/png"]
      return @fileTypeEnum.IMG
    if rawType is "text/html"
      return @fileTypeEnum.HTML
    if rawType is "text/css"
      return @fileTypeEnum.CSS
    if rawType is "application/x-javascript"
      return @fileTypeEnum.JS
    return @fileTypeEnum.NONE


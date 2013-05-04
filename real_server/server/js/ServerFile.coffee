class window.ServerFile extends Backbone.Model
  defaults:
    name: ""
    size: 0
    contents: ""
    type: ""
    fileType: ""
    isLandingPage: false

  fileTypeEnum:
    HTML: "HTML",
    CSS: "CSS",
    JS: "JS",
    IMG: "IMG",
    NONE: "NONE"

  initialize: () ->
    @on("change:type", @updateFileType)
    @updateFileType()

    @on("change:contents", @updateContentsInFileStore)
    @on("change:isLandingPage", @handleIsLandingPageChange)

    if @get("fileType") is @fileTypeEnum.HTML
      @initIsLandingPage()

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

  updateContentsInFileStore: =>
    fileStore = window.fileStore
    fileStore.addFile(@get("name"), @get("size"), @get("type"), @get("contents"))

  initIsLandingPage: =>
    landingPageName = localStorage["landingPage"]
    if landingPageName is @get("name")
      @set("isLandingPage", true)

  handleIsLandingPageChange: =>
    if @get("isLandingPage")
      localStorage["landingPage"] = @get("name")
    else
      localStorage.removeItem("landingPage")



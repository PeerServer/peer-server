'''
  Tracks user-uploaded files, and their edit/production state.
'''

class window.ServerFileCollection extends Backbone.Collection
  model: ServerFile

  localStorage: new Backbone.LocalStorage("ServerFileCollection")

  initialize: ->

  comparator: (serverFile) =>
    return serverFile.get("name")

  getLandingPage: ->
    landingPage = @find (serverFile) ->
      return serverFile.get("isLandingPage") and serverFile.get("isProductionVersion")

    if landingPage
      return {"fileContents": landingPage.get("contents"), "filename": landingPage.get("name"), "type": "text/html"}
    else
      return {"fileContents": "Under development... (set a landing page)", "filename": "404.html", "type": "text/html"}

  hasFile: (filename) =>
    return @findWhere(name: filename)

  getContents: (filename) =>
    serverFile = @findWhere(name: filename, isProductionVersion: true)
    contents = ""
    if serverFile
      contents = serverFile.get("contents")

   createProductionVersion: =>
     productionFiles = @where(isProductionVersion: true)
     _.each productionFiles, (serverFile) =>
       serverFile.destroy()

     developmentFiles = @where(isProductionVersion: false)
     _.each developmentFiles, (serverFile) =>
       attrs = _.clone(serverFile.attributes)
       attrs.id = null
       copy = new ServerFile(attrs)
       copy.set("isProductionVersion", true)
       @add(copy)

    forEachDevelopmentFile: (fn) =>
      @each (serverFile) ->
        if not serverFile.get("isProductionVersion")
          fn(serverFile)


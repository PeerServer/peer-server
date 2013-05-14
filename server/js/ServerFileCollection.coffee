'''
  Tracks user-uploaded files, and their edit/production state.
'''

class window.ServerFileCollection extends Backbone.Collection
  model: ServerFile

  localStorage: new Backbone.LocalStorage("ServerFileCollection")

  initialize: ->
    @fetch(success: @checkForNoFiles)

  checkForNoFiles: =>
    return if @length > 0

    # Initialize the collection with a index and 404 page (both required),
    # if the user's file collection is empty
    index = new ServerFile(name: "index.html", size: 0, type: "text/html", contents: @indexTemplate, isRequired: true)
    notFound = new ServerFile(name: "404.html", size: 0, type: "text/html", contents: @notFoundTemplate, isRequired: true)
    @add(index)
    @add(notFound)
    
    index.save()
    notFound.save()

    # Create an initial production version
    @createProductionVersion()

  comparator: (serverFile) =>
    return serverFile.get("name")

  getLandingPage: ->
    landingPage = @find (serverFile) ->
      return serverFile.get("name") is "index.html" and serverFile.get("isProductionVersion")

    if landingPage
      data =
        fileContents: landingPage.get("contents"),
        filename: landingPage.get("name"),
        type: "text/html"
    else
      data =
        fileContents: @indexTemplate,
        filename: "index.html",
        type: "text/html"

    return data

  hasFile: (filename) =>
    return @findWhere(name: filename)

  getContents: (filename) =>
    serverFile = @findWhere(name: filename, isProductionVersion: true)
    contents = ""
    if serverFile
      contents = serverFile.get("contents")
    return contents

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
       copy.save()

    # Iterates over the development files,
    # calling fn on each development file
    forEachDevelopmentFile: (fn) =>
      @each (serverFile) ->
        if not serverFile.get("isProductionVersion")
          fn(serverFile)

    # --- DEFAULT FILE TEMPLATES ---

    indexTemplate: """
      <html>
        <body>
          Hello, world.
        </body>
      </html>
      """

    notFoundTemplate: """
      <html>
        <body>
          404 - page not found
        </body>
      </html>
      """



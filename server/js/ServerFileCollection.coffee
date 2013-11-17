'''
  Tracks user-uploaded files, and their edit/production state.
'''

class window.ServerFileCollection extends Backbone.Collection
  model: ServerFile

  initialize: ->
    @on("add", @onServerFileAdded)

  initLocalStorage: (namespace) =>
    @localStorage = new Backbone.LocalStorage(namespace + "-ServerFileCollection")
    @fetch(success: @checkForNoFiles)
    @on("reset", @checkForNoFiles)

  onServerFileAdded: (serverFile) =>
    if not @overwriteRequiredPages(serverFile)
      serverFilesWithName = @filter (otherServerFile) ->
        return serverFile.get("name") is otherServerFile.get("name") \
          and not serverFile.get("isProductionVersion") \
          and not otherServerFile.get("isProductionVersion")

      _.sortBy serverFilesWithName, (otherServerFile) ->
        return otherServerFile.get("dateCreated")

      numToAppend = 1
      index = 1
      while index < serverFilesWithName.length
        filenameAndExtension = @filenameAndExtension(serverFile.get("name"))
        newName = filenameAndExtension.filename +
          "-" + numToAppend + filenameAndExtension.ext
        if not @isFilenameInUse(newName)
          serverFile.save("name", newName)
          index++
        numToAppend++

    serverFile.save()

  overwriteRequiredPages: (serverFile) =>
    didOverwrite = false

    _.each ["index.html", "404.html"], (pageName) =>
      if pageName is "index.html"
        defaultPage = @indexTemplate
      else
        defaultPage = @template404

      if serverFile.get("name") is pageName and not serverFile.get("isProductionVersion")

        serverFilesWithName = @filter (otherServerFile) ->
          return serverFile.get("name") is otherServerFile.get("name") \
            and serverFile isnt otherServerFile \
            and otherServerFile.get("contents") is defaultPage

        _.each serverFilesWithName, (serverFileWithName) =>
          serverFileWithName.destroy()
          serverFile.set("isRequired", true)
          didOverwrite = true

    return didOverwrite

  isFilenameInUse: (filename) =>
    result = @find (serverFile) ->
      return serverFile.get("name") is filename \
        and not serverFile.get("isProductionVersion")
    return result isnt undefined

  filenameAndExtension: (filename) =>
    match = filename.match(/(.*)(\..*)$/)
    if match isnt null and match.length is 3
      return { filename: match[1], ext: match[2] }
    return { filename: filename, ext: "" }

  checkForNoFiles: =>
    return if @length > 0
    # Initialize the collection with a index and 404 page (both required),
    # if the user's file collection is empty
    index = new ServerFile(name: "index.html", size: 0, type: "text/html", contents: @indexTemplate, isRequired: true)
    notFound = new ServerFile(name: "404.html", size: 0, type: "text/html", contents: @template404, isRequired: true)
    @add(index)
    @add(notFound)

    index.save()
    notFound.save()

    # Create an initial production version
    @createProductionVersion()

  comparator: (serverFile) =>
    filenameAndExtension = @filenameAndExtension(serverFile.get("name"))
    return filenameAndExtension.filename

  getLandingPage: ->
    landingPage = @find (serverFile) ->
      return serverFile.get("name") is "index.html" and serverFile.get("isProductionVersion")

    if landingPage
      data =
        fileContents: landingPage.get("contents"),
        filename: landingPage.get("name"),
        type: "text/html"
    else
      console.error("ERROR: No index.html file exists in the file collection, may break when trying to use getters.")
      data =
        fileContents: @indexTemplate,
        filename: "index.html",
        type: "text/html"
    return data

  get404Page: =>
    # TODO -- getContents and getFileType etc depend on the 404.html page actually existing
    #  in the file collection, which they always should.
    page = @find (serverFile) ->
      return serverFile.get("name") is "404.html" and serverFile.get("isProductionVersion")
    console.log "Returning 404 page."
    if page
      data =
        fileContents: page.get("contents"),
        filename: page.get("name"),
        type: page.get("fileType")
    else
      console.error("ERROR: No 404 file exists in the file collection, may break when trying to use getters.")
      data =
        fileContents: @template404,
        filename: "404.html",
        type: "HTML"
    return data

  hasProductionFile: (filename) =>
    return @findWhere(name: filename, isProductionVersion: true)

  getFileType: (filename) =>
    serverFile = @findWhere(name: filename, isProductionVersion: true)
    fileType = "UNKNOWN"
    if serverFile
      fileType = serverFile.get("fileType")
    return fileType

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

  template404: """
    <html>
      <body>
        404 - page not found
      </body>
    </html>
    """



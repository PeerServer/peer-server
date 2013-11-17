class window.ClientServerUnarchiver

  constructor: (params) ->
    @serverFileCollection = params.serverFileCollection
    @routeCollection = params.routeCollection
    @userDatabase = params.userDatabase
    contents = params.contents

    @clearAll()

    zip = new JSZip(contents)

    productionFiles = zip.filter (relativePath, file) =>
      return /^live_version\/.+/.test(relativePath)

    developmentFiles = zip.filter (relativePath, file) =>
      return /^edited_version\/.+/.test(relativePath)

    _.each(productionFiles, _.bind(@processFile, @, true))
    _.each(developmentFiles, _.bind(@processFile, @, false))

    database = zip.file("database.db")
    if database
      @userDatabase.fromJSONArray(database.data)

  # TODO (?) Unify clearing code with server collection view
  clearAll: =>
    while model = @serverFileCollection.first()
      model.destroy()
    while model = @routeCollection.first()
      model.destroy()
    @serverFileCollection.reset()
    @routeCollection.reset()
    @userDatabase.clear()

  processFile: (isProductionVersion, file) =>
    name = file.name.replace(/^(live|edited)_version\//, "")
    contents = file.data
    isRoute = /.+\.route\.js$/.test(name)

    fileType = ""
    ext = name.match(/.*\.(.*?)$/)
    if ext
      ext = ext[1]
      fileType = ServerFile.fileExtToFileType[ext] or ""

      if ext in ["jpg", "png", "jpeg"]
        contents = @alterContentsForImage(ext, contents)

    if isRoute
      @addRoute(name, contents, isProductionVersion)
    else
      @addServerFile(name, contents, fileType, isProductionVersion)

  addRoute: (name, contents, isProductionVersion) =>
    contents = JSON.parse(contents)
    name = name.replace(/\.route\.js$/, "")
    routePath = contents.routePath
    routeCode = contents.routeCode

    route = new Route(
      name: name,
      routePath: routePath,
      routeCode: routeCode,
      isProductionVersion: isProductionVersion)
    @routeCollection.add(route)
    route.save()

  addServerFile: (name, contents, fileType, isProductionVersion) =>
    serverFile = new ServerFile(
      name: name,
      contents: contents,
      fileType: fileType,
      isProductionVersion: isProductionVersion)
    @serverFileCollection.add(serverFile)

  alterContentsForImage: (ext, contents) =>
    contents = btoa(contents)
    if ext in ["jpg", "jpeg"]
      return "data:image/jpeg;base64," + contents
    if ext is "png"
      return "data:image/png;base64," + contents


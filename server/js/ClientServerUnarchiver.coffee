class window.ClientServerUnarchiver
  
  constructor: (params) ->
    @serverFileCollection = params.serverFileCollection
    @routeCollection = params.routeCollection
    @userDatabase = params.userDatabase
    contents = params.contents

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

  processFile: (isProductionVersion, file) =>
    name = file.name.replace(/^(live|edited)_version\//, "")
    contents = file.data
    isRoute = /.+\.route\.js$/.test(name)

    if isRoute
      @addRoute(name, contents, isProductionVersion)
    else
      @addServerFile(name, contents, isProductionVersion)

  addRoute: (name, contents, isProductionVersion) =>
    contents = JSON.parse(contents)
    name = name.replace(/\.route\.js$/, "")
    routePath = contents.routePath
    routeCode = contents.routePath

    route = new Route(
      name: name,
      routePath: routePath,
      routeCode: routeCode,
      isProductionVersion: isProductionVersion)
    @routeCollection.add(route)
    route.save()

  addServerFile: (name, contents, isProductionVersion) =>
    serverFile = new ServerFile(
      name: name,
      contents: contents,
      isProductionVersion: isProductionVersion)
    @serverFileCollection.add(serverFile)
    serverFile.save()


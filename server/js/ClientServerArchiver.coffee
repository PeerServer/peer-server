class window.ClientServerArchiver
  
  constructor: (params) ->
    @serverFileCollection = params.serverFileCollection
    @routeCollection = params.routeCollection
    @userDatabase = params.userDatabase
    @button = params.button

    @button.click(@archive)

  archive: =>
    zip = new JSZip()

    productionFolder = zip.folder("live_version")
    developmentFolder = zip.folder("edited_version")

    @serverFileCollection.each (serverFile) =>
      if serverFile.get("isProductionVersion")
        folder = productionFolder
      else
        folder = developmentFolder
        
      folder.file(serverFile.get("name"), serverFile.get("contents"))

    @routeCollection.each (route) =>
      if route.get("isProductionVersion")
        folder = productionFolder
      else
        folder = developmentFolder

      contents = {}
      contents.routePath = route.get("routePath")
      contents.routeCode = route.get("routeCode")
      folder.file(route.get("name") + ".route.js",
        JSON.stringify(contents, null, " "))

    zip.file("database.db", @userDatabase.toString())

    content = zip.generate()
    location.href = "data:application/zip;base64," + content


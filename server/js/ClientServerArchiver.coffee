class window.ClientServerArchiver
  
  constructor: (params) ->
    @serverName = params.serverName
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
      
      filename = serverFile.get("name")
      ext = ServerFile.fileTypeToFileExt[serverFile.get("fileType")] or ""
      if ext isnt "" and filename.match("\." + ext + "$") is null
        filename += "." + ext

      if serverFile.get("fileType") is ServerFile.fileTypeEnum.IMG
        imageData = serverFile.get("contents").replace(/data:image\/.*?;base64,/, "")
        folder.file(filename, imageData, {base64: true})
      else
        folder.file(filename, serverFile.get("contents"))

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

    blob = zip.generate({type:"blob"})

    anchor = document.createElement("a")
    anchor.href = window.URL.createObjectURL(blob)
    anchor.download = "#{@serverName}.zip"
    $anchor = $(anchor)
    $anchor.hide()
    $("body").append($anchor)
    anchor.click()
    $anchor.remove()


# Initialization code.

$(document).ready ->
  # Initialize global state
  serverFileCollection = new ServerFileCollection()
  routeCollection = new RouteCollection()
  userDatabase = new UserDatabase()

  appView = new AppView(
    serverFileCollection: serverFileCollection,
    routeCollection: routeCollection,
    userDatabase: userDatabase)
  
  clientServer = new ClientServer(
    serverFileCollection: serverFileCollection,
    routeCollection: routeCollection,
    appView: appView,
    userDatabase: userDatabase)

  params = URI.parseQuery(document.location.search)
  if _.has(params, "template") and params.template isnt "blank"
    templateUri = params.template
    serverTemplate = new ServerTemplateModel(
      templateUri: templateUri,
      handleZipFcn: appView.handleZipFile)

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
    serverFileCollection, routeCollection, appView, userDatabase)

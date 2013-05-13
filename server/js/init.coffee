# Initialization code. 

$(document).ready ->
  # Initialize global state
  serverFileCollection = new ServerFileCollection()
  routeCollection = new RouteCollection()
  appView = new AppView(serverFileCollection: serverFileCollection, routeCollection: routeCollection)

# Initialization code. 

$(document).ready ->
  # Initialize global state
  serverFileCollection = new ServerFileCollection()
  appView = new AppView(collection: serverFileCollection)
  window.webRTC = new WebRTC(serverFileCollection, appView.setClientBrowserLink)


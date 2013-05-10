# Initialization code. 

$(document).ready ->
  # Initialize global state
  serverFileCollection = new ServerFileCollection()
  new AppView(collection: serverFileCollection)
  new WebRTC(serverFileCollection)


# Initialization code. 


$(document).ready ->
  webRTC = new WebRTC(document.getElementById("container").contentWindow.document.documentElement) 


  # This event is triggered by the "onclick" of an a href tag pointing to some file
  #   on the server-browser. The onclick event trigger is set up in webRTC's html_processor 
  #   when the anchor tags are parsed.
  # The event is triggered on the parent frame's document (ie, on the top-level page assuming that there is 
  #   no iframe nesting going on). 
  # This listener responds to the relative link being clicked by sending a request for the file 
  #   down to the htmlProcessor, which will handle fetching the file and responding to the fetched
  #   file to simulate page navigation. 
  $(document).on "relativeLinkClicked", (evt, href) =>
    console.log "REQUESTING FILE " + href + "...."
    webRTC.htmlProcessor.requestFile(href, "alink")
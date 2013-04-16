# Initialization code. 


$(document).ready ->
  webRTC = new WebRTC(document.getElementById("container").contentWindow.document.documentElement) 
  # webRTC.onMessageCallback = function(message) {
  # final_html = intercept(message) // handle relative link insertion/loading (relative a hrefs, css/js, img src
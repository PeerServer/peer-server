
# Initialization code. 

$(document).ready ->

  # Initialize global state
  console.log("Initializing global state")
  window.fileStore = new FileStore()

  webRTC = new WebRTC(window.fileStore)

  $("#send-content").click ->
      webRTC.sendEvent("textAreaValueChanged", $("textarea").val())

  # Prevent the page from opening the file directly on drop.
  $("#file-drop").bind 'drop dragover', (e) ->
    e.preventDefault()

  window.drop_handler = new DropHandler(window.fileStore, $("#file-list"), $("#file-name"), $("#file-contents"))
  $("#file-drop").bind("drop", window.drop_handler.handleDrop)

  # UI glue for managing the selection element
  $("#file-list").change ->
    selected_file = $("#file-list option:selected").val()
    $("#file-contents").val(window.fileStore.getFile(selected_file))
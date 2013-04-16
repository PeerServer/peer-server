
# Initialization code. 

$(document).ready ->

  # Initialize global state
  console.log("Initializing global state")
  window.file_store = new FileStore()

  webRTC = new WebRTC()

  $("#send-content").click ->
      webRTC.sendEvent("textAreaValueChanged", $("textarea").val())

  # Prevent the page from opening the file directly on drop.
  $("#file-drop").bind 'drop dragover', (e) ->
    e.preventDefault()

  window.drop_handler = new DropHandler(window.file_store, $("#file-list"), $("#file-name"), $("#file-contents"))
  $("#file-drop").bind("drop", window.drop_handler.handleDrop)

  # UI glue for managing the selection element
  $("#file-list").change ->
    selected_file = $("#file-list option:selected").val()
    $("#file-contents").val(window.file_store.getFile(selected_file))
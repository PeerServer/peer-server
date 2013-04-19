# Initialization code. 

$(document).ready ->

  # Initialize global state
  console.log("Initializing global state")
  window.fileStore = new FileStore()

  webRTC = new WebRTC(window.fileStore, $("#user-portal"))

  editor = new CodeEditor(ace.edit("file-contents"))

  # Prevent the page from opening the file directly on drop.
  $("#file-drop").bind 'drop dragover', (e) ->
    e.preventDefault()

  window.drop_handler = new DropHandler(window.fileStore, $("#file-list"), editor)
  $("#file-drop").bind("drop", window.drop_handler.handleDrop)

  $("#send-content").click =>
      webRTC.sendEvent("textAreaValueChanged", editor.getCodeContents())

  editor.setCodeContents("<!-- Code goes here -->")

  # TODO save the editor's contents to the relevant file (or make a new file for it) when the user changes the code.
  # TODO adjust editor's mode based on type of file (js/html/css etc)

  # UI glue for managing the selection element
  $("#file-list").change =>
    selected_file = $("#file-list option:selected").val()
    editor.setCodeContents(window.fileStore.getFileContents(selected_file))
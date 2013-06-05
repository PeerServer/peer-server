# Initialization code.

$(document).ready ->
  # Initialize global state
  ENTER_KEY = 13
  $("#serverName").keyup (evt) ->
    if evt.keyCode is ENTER_KEY
      name = $('#serverName').val()
      window.location.href = "/server/" + name

  $("#create-server").click (evt) ->
    name = $('#serverName').val()
    this.href = "/server/" + name
# The Fake Ajax class the jquery 'ajax' function call to send WebRTC requests
class window.FakeAjax
  jqAjax: (path, options) =>
    if "success" of options
      @success = options["success"]
    if "failure" of options
      @failure = options["failure"]

    console.log "success is now:" + @success
    top.window.webRTC.ajaxClient.requestAjax(path, @success)


# This code patches jquery so that the $.ajax method is redirected to the
# FakeAjax code above
$.ajax = (url, options) ->
    fajax = new FakeAjax()
    return fajax.jqAjax(url, options)


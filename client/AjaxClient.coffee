'''
  Tracks Ajax requests, implementing a subset of ajax.
'''

class window.AjaxClient
  constructor: (@sendEvent, @socketIdFcn) ->
    @outstandingRequests = {}  # Map of ajax requestId to callbacks.

  requestAjax: (path, options, successCallback, errorCallback) =>
    requestId = Math.random().toString(36).substr(2,14)

    if typeof callback isnt "undefined" and typeof callback isnt "function"
      console.error "error: callback is not a function!"
      return
    @outstandingRequests[requestId] = {
     "successCallback": successCallback,
     "errorCallback": errorCallback,
     "timestamp": (new Date().getTime())
    }
    data = {
      "filename": path,  # Path is more accurate than filename, but use filename for consistency.
      "socketId": @socketIdFcn(),
      "requestId": requestId
      "options": options
      "type": "ajax"
    }
    @sendEvent("requestFile", data)

  receiveAjax: (data) =>
    if not data.requestId
      console.error "received AJAX response with no request ID"
      return
    # Remove request out of the outstanding map, if it exists
    request = @outstandingRequests[data.requestId]
    if not request or typeof request is "undefined"
      console.error "received ajax response for a nonexistent request id"
      return
    delete @outstandingRequests[data.requestId]

    if not data.errorThrown
      request.successCallback(data.fileContents)
    else
      # TODO (low priority): first argument should technically be a jqXHR object.
      request.errorCallback({}, data.textStatus, data.errorThrown)
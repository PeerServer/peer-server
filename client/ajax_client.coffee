class window.AJAXClient
  constructor: (@sendEvent, @socketIdFcn) ->
    # Do nothing
    @outstandingRequests = {}
  
  requestAjax: (path, options, callback) =>
    console.log "sending ajax request for path: " + path + " on socket id " + @socketIdFcn()
    requestId = Math.random().toString(36).substr(2,10)

    if typeof callback isnt "undefined"
      if typeof callback isnt "function"
        throw "callback must be a function"

      @outstandingRequests[requestId] = {
       "callback": callback,
       "timestamp": (new Date().getTime())
      }
    
    data = {
      "path": path,
      "socketId": @socketIdFcn(),
      "requestId": requestId
      "options": options
    }

    console.log "sending ajax request:"
    console.log data

    @sendEvent("requestAjax", data)

  receiveAjax: (data) =>
    console.log "Received ajax response:" + data.requestId
    console.log data

    if 'requestId' not of data
      console.log "received AJAX response with no request ID"
      return

    if 'contents' not of data
      console.log "received AJAX response with no contents"
      return

    # "pop" a request out of the outstanding map, if it exists
    request = @outstandingRequests[data.requestId]
    delete @outstandingRequests[data.requestId]

    if typeof request is "undefined"
      console.log "Got ajax response with no callback"
      return

    request.callback(data['contents'])

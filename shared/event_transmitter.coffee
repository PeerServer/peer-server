class window.EventTransmitter
  
  constructor: ->
    @eventCallbacks = {}

  addEventCallback: (eventName, callback) =>
    eventCallbacks = @eventCallbacks[eventName]
    if not eventCallbacks then eventCallbacks = []
    eventCallbacks.push(callback)
    @eventCallbacks[eventName] = eventCallbacks
  
  sendEvent: (dataChannel, eventName, data) =>
    #console.log("send event " + eventName, JSON.stringify({ "eventName": eventName, "data": data }))
    # console.log JSON.stringify({ "eventName": eventName, "data": data })
    # dataChannel.send(JSON.stringify({ "eventName": eventName, "data": data }))
    dataChannel.send({ "eventName": eventName, "data": data })

  receiveEvent: (messageEventData) =>
    eventName = messageEventData.eventName
    messageData = messageEventData.data
    # console.log("receive event " + eventName, messageData)
    eventCallbacks = @eventCallbacks[eventName]
    if eventCallbacks
      for eventCallback in eventCallbacks
        eventCallback(messageData)

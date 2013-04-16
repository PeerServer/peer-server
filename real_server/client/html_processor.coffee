class window.HTMLProcessor

  constructor: (@sendEvent) ->
    @requestedFilenamesToElement = {}

  processHTML: (html, completionCallback) =>
    @completionCallback = completionCallback
    
    container = document.createElement("html")
    container.innerHTML = html.replace(/<\/?html>/g, "")
    $container = $(container)
    
    @container = $container

    @processImages($container)
#    @processScripts($container)
#    @processStyleSheets($container)
#    @processLinks($container)

  processImages: ($container) =>
    images = $container.find("img")
    images.each (index, el) =>
      $el = $(el)
      filename = $el.attr("src")
      if @isInternalFile(filename)
        @requestedFilenamesToElement[filename] = $el
        @requestFile(filename)

  isInternalFile: (filename) =>
    return filename.match(/(?:https?:\/\/)/) is null
    
  requestFile: (filename) =>
    @sendEvent("requestFile", filename)

  receiveFile: (data) =>
    console.log("RF", @requestedFilenamesToElement)
    console.log("receive file", data)
    filename = data.filename
    fileContents = data.fileContents

    $element = @requestedFilenamesToElement[filename]
    if $element
      delete @requestedFilenamesToElement[filename]
      if $element.attr("src") and $element[0].tagName is "IMG"
        $element.attr("src", fileContents)
        
    if Object.keys(@requestedFilenamesToElement).length is 0 and @completionCallback
      @completionCallback(@container[0].outerHTML)

class window.HTMLProcessor

  constructor: (@sendEvent) ->
    @requestedFilenamesToElement = {}
    @container = null
    @completionCallback = null

  processHTML: (html, completionCallback) =>
    @completionCallback = completionCallback
    
    container = document.createElement("html")
    container.innerHTML = html.replace(/<\/?html>/g, "")
    @container = $(container)
    
    @processImages()
    @processScripts()
    @processStyleSheets()
    @processLinks()

    # Ensure that this is called just in case there is nothing to be processed
    @checkForProcessCompletion()

  processImages: =>
    @processElementsWithAttribute("img[src]", "src")
        
  processScripts: =>
    @processElementsWithAttribute("script[src]", "src")

  processStyleSheets: =>
    @processElementsWithAttribute("link[rel=\"stylesheet\"]", "href")

  processLinks: =>
    # TODO
#    @processElementsWithSRCAttribute("a[href]", "href")
    
  processElementsWithAttribute: (elSelector, attrSelector) =>
    elements = @container.find(elSelector)
    elements.each (index, el) =>
      $el = $(el)
      filename = $el.attr(attrSelector)
      if @isInternalFile(filename)
        @requestedFilenamesToElement[filename] = $el
        @requestFile(filename)

  isInternalFile: (filename) =>
    return filename.match(/(?:https?:\/\/)|(?:data:)/) is null
    
  requestFile: (filename) =>
    @sendEvent("requestFile", filename)

  receiveFile: (data) =>
    console.log("receive file", data)
    filename = data.filename
    fileContents = data.fileContents

    $element = @requestedFilenamesToElement[filename]
    if $element
      delete @requestedFilenamesToElement[filename]
      
      if $element.attr("src") and $element[0].tagName is "IMG" 
        $element.attr("src", fileContents)
      else if $element.attr("src") and $element[0].tagName is "SCRIPT"
#        $element.removeAttr("src")
#        $element.append(fileContents)
        script = document.createElement('script')
        script.type = 'text/javascript'
        script.innerHTML = fileContents
#        $element.replaceWith($("<script/>").append(fileContents))
#        $("<script/>").append(fileContents).insertAfter($element)
        $(script).insertAfter($element)
        $element.remove()
      else if $element[0].tagName is "LINK"
        $element.replaceWith("<style>" + fileContents + "</style>")
#        @container.find("head").append($element)
        
    @checkForProcessCompletion()

  checkForProcessCompletion: =>
    if Object.keys(@requestedFilenamesToElement).length is 0 and @completionCallback
      @completionCallback(@container[0].outerHTML)

class window.HTMLProcessor

  constructor: (@sendEvent, @setDocumentElementInnerHTML, @socketIdFcn) ->
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
    @processElementsWithAttribute("img[src]", "src", "image")
        
  processScripts: =>
    @processElementsWithAttribute("script[src]", "src", "script")

  processStyleSheets: =>
    @processElementsWithAttribute("link[rel=\"stylesheet\"]", "href", "stylesheet")
    @processElementsWithAttribute("link[rel=\'stylesheet\']", "href", "stylesheet")


  # Links are handled somewhat differently in that the contents cannot be injected on page load. 
  #   Instead, here we set up an onclick function for each anchor tag, and make the href a no-op (by 
  #   placing return false in the onclick function.)
  #   External anchor tags are handled by having them open in a new window ("_blank"). Another option
  #   here would be to have them open in the top window (ie, the main actual window rather than the frame)
  #   by using "target='_top'.
  # TODO: links to non-text/non-html files do not work (ie, you cannot link to an image and have it 
  #   display correctly likely due to the MIME type)
  # TODO: back button support (currently does not work). This probably involves storing a stack of past page 
  #   history in localStorage and intercepting presses of the back button on the top page. 
  processLinks: =>
    elements = @container.find("a[href]")
    elements.each (index, el) =>
      $el = $(el)
      href = $el.attr("href")  # Don't change the href so that the hover behavior is correct -- instead, it 
      # will be ignored because onclick returns false. 
      if @isInternalFile(href)
        $el.attr("onclick", @triggerOnParentString("relativeLinkClicked", href))
      else 
        $el.attr("target", "_blank")

  # Triggers an event on the top (actual) window, passing in href as the parameter. 
  #  The return false is important so that the href portion of the link is ignored. 
  triggerOnParentString: (eventName, href) =>
    return "javascript:top.$(top.document).trigger('" + eventName + "', ['" + href + "']);return false;"

  processElementsWithAttribute: (elSelector, attrSelector, type) =>
    elements = @container.find(elSelector)
    elements.each (index, el) =>
      $el = $(el)
      filename = $el.attr(attrSelector)
      if @isInternalFile(filename)
        @requestedFilenamesToElement[filename] = $el
        @requestFile(filename, type)

  isInternalFile: (filename) =>
    return filename.match(/(?:https?:\/\/)|(?:data:)/) is null
    

  # Note that requestFile is also called externally (ie, by the global function that
  #   handles a href tags being clicked.)  
  requestFile: (filename, type) =>
    console.log "sending socket id " + @socketIdFcn()
    data = 
      "filename": filename
      "socketId": @socketIdFcn()
      "type": type
    @sendEvent("requestFile", data)

  receiveFile: (data) =>
    console.log("receive file", data)
    filename = data.filename
    fileContents = data.fileContents
    type = data.type  # Same as what we passed along in request file.

    # Handles an a href link file type being sent in. This should only occur when the user
    #  has clicked an "a href" tag, and so we change the entire frame's contents
    #  to be the received html file. 
    # Setting the document inner HTML calls the webRTC method passed in, which initiates
    #   another round of setting up the HTML for the frame (with processing). 
    if type is "alink"
      console.log "Is alink"
      @setDocumentElementInnerHTML data.fileContents
    else 
      $element = @requestedFilenamesToElement[filename]
      if $element
        delete @requestedFilenamesToElement[filename]
        
        if $element.attr("src") and $element[0].tagName is "IMG" 
          $element.attr("src", fileContents)
        else if $element.attr("src") and $element[0].tagName is "SCRIPT"
  #        $element.removeAttr("src")
  #        $element.append(fileContents)
        
          iframe = document.getElementById("container")
          script = iframe.contentWindow.document.createElement("script")
          script.type = "text/javascript"
          script.text = fileContents
          console.log(fileContents)
          iframe.contentWindow.document.head.appendChild(script)
          
  #        $element.after(script)
          $element.remove()
          
  #        $element.replaceWith($("<script/>").append(fileContents))
  #        $("<script/>").append(fileContents).insertAfter($element)
  #        $(script).insertAfter($element)
  #        $element.after(script)
  #        document.body.appendChild(script)
  #        console.log($element[0].parentNode)
  #        $element[0].parentNode.appendChild(script)
  #        $element.remove()
        else if $element[0].tagName is "LINK"
          $element.replaceWith("<style>" + fileContents + "</style>")
  #        @container.find("head").append($element)        
    @checkForProcessCompletion()

  checkForProcessCompletion: =>
    if Object.keys(@requestedFilenamesToElement).length is 0 and @completionCallback
      @completionCallback(@container[0].outerHTML)

class window.HTMLProcessor

  constructor: (@sendEvent, @setDocumentElementInnerHTML, @getIDFn) ->
    @requestedFilenamesToElement = {}
    @container = null
    @completionCallback = null

  processHTML: (html, completionCallback) =>
    @completionCallback = completionCallback
    @scriptMapping = {}

    container = document.createElement("html")
    container.innerHTML = html.replace(/<\/?html>/g, "")
    @container = $(container)

    @processTitle()
    @processImages()
    @processScripts()
    @processStyleSheets()
    @processLinks()

    # Ensure that this is called just in case there is nothing to be processed
    @checkForProcessCompletion()

  processTitle: =>
    elements = @container.find("title")
    elements.each (index, el) =>
      $el = $(el)
      document.title = $el.text()

  # Returns HTML for displaying a "theserver.com/image.jpg" url page
  processImageAsHTML: (html, completionCallback) =>
    @completionCallback = completionCallback
    container = document.createElement("html")
    @container = $(container)
    # Set the style so that the image is centered
    # TODO: possibly soup this up with zooming in and out of images (just requires a script
    #  listening to the window size and resizing if needed, plus a zoom-in zoom-out cursor)
    img = "<img style='text-align:center; position:absolute; margin:auto; top:0;right:0;bottom:0;left:0;' "
    img += " src='" + html + "' />"
    @container.append($(img))
    @completionCallback(@container[0].outerHTML)

  processImages: =>
    @processElementsWithAttribute(@container.find("img[src]"), "src", "image")

  processScripts: =>
    @processElementsWithAttribute(@container.find("script[src]"), "src", "script")

  processStyleSheets: =>
    elements = @container.find("link[rel=\"stylesheet\"]")
    elements.add(@container.find("link[rel=\'stylesheet\']"))  # For Chrome, likely. Not needed for Firefox
    @processElementsWithAttribute(elements, "href", "stylesheet")

  # Links are handled somewhat differently in that the contents cannot be injected on page load.
  #   Instead, here we set up an onclick function for each anchor tag, and make the href a no-op (by
  #   placing return false in the onclick function.)
  #   External anchor tags are handled by having them open in a new window ("_blank"). Another option
  #   here would be to have them open in the top window (ie, the main actual window rather than the frame)
  #   by using "target='_top'.
  # TODO it might be worth making this more robust with identifying internal files.
  processLinks: =>
    elements = @container.find("a[href]")
    elements.each (index, el) =>
      $el = $(el)
      # Don't change the href so that the hover behavior is correct --
      # instead, it will be ignored because onclick returns false.
      href = $el.attr("href")
      # Ignore local links
      if href[0] is "#"
        return
      else if @isInternalFile(href)
        $el.attr("onclick", @triggerOnParentString("relativeLinkClicked", href))
      else
        $el.attr("target", "_blank")


  # Triggers an event on the top (actual) window, passing in href as the parameter.
  #  The return false is important so that the href portion of the link is ignored.
  triggerOnParentString: (eventName, href) =>
    return "javascript:top.$(top.document).trigger('" + eventName + "', ['" + href + "']);return false;"

  processElementsWithAttribute: (elements, attrSelector, type) =>
    elements.each (index, el) =>
      $el = $(el)
      filename = $el.attr(attrSelector)
      if @isInternalFile(filename)
        if filename of @requestedFilenamesToElement
          @requestedFilenamesToElement[filename].push($el)
          # Do not need to request this file because a request is already pending for it.
        else
          @requestedFilenamesToElement[filename] = [$el]
          @requestFile(filename, type)

  isInternalFile: (filename) =>
    # Hack -- basically, an internal file can't start with "#" and shouldn't match http/https.
    if (filename[0] != "#" and filename.match(/(?:https?:\/\/)|(?:data:)/) is null)
      return true
    return false

  # Note that requestFile is also called externally (ie, by the global function that
  #   handles a href tags being clicked.)
  requestFile: (filename, type) =>
    data =
      "filename": filename
      "socketId": @getIDFn()
      "type": type
    @sendEvent("requestFile", data)

  #  For filenames, removes any trailing slash if it exists.
  removeTrailingSlash: (str) =>
    return str if not str or str is ""
    if str.charAt(str.length - 1) is "/"
      return str.substr(0, str.length - 1)
    return str

  receiveFile: (data) =>
    filename = @removeTrailingSlash(data.filename)
    fileContents = data.fileContents
    type = data.type  # Same as what we passed along in request file.
    fileType = data.fileType  # IMG, JS, CSS, HTML, etc.

    # Handles a file type being sent in that refreshes the entire page.
    # Change the entire frame's contents to be the received html file.
    # Setting the document inner HTML calls the webRTC method passed in, which initiates
    #   another round of setting up the HTML for the frame (with processing).
    if type is "alink" or type is "backbutton" or type is "initialLoad" or type is "submit"
      @setDocumentElementInnerHTML({"fileContents": data.fileContents, "filename": filename, "fileType": fileType}, type)
    else
      @handleSupportingFile(data, filename, fileContents, type, fileType)


  handleFileForElem: ($element, data, filename, fileContents) =>
    if not $element
      console.error "element is null: " + filename
      return
    if $element.attr("src") and $element[0].tagName is "IMG"
      $element.attr("src", fileContents)
    else if $element.attr("src") and $element[0].tagName is "SCRIPT"
      $element.removeAttr("src")  # TODO remove later?
      $element.attr("todo-replace", "replace")
      @scriptMapping[data.filename] = fileContents
      # NOTE: this is dangerous b/c we might get encoded if the filename has bad characters in it
      #   (which I think is plausible), and then we're screwed when we try to find the non-encoded file name
      #   contents using the encoded file name we pull out when we execute the script. It would be safest to include a
      #   unique ID with each file (perhaps imparted by the client-server filestore) that we can use instead.
      #   Basically any unique ID here is fine.
      $element.append(data.filename)
    else if $element[0].tagName is "LINK"
      $element.replaceWith("<style>" + fileContents + "</style>")
    else
      console.log "unknown element type, could not be processed:"
      console.log $element


  handleSupportingFile: (data, filename, fileContents, type, fileType) =>
    elems = @requestedFilenamesToElement[filename]
    if not elems
      console.error "received file not in request list: " + filename
      return
    for $element in elems
      @handleFileForElem($element, data, filename, fileContents)
    delete @requestedFilenamesToElement[filename]
    @checkForProcessCompletion()

  checkForProcessCompletion: =>
    if Object.keys(@requestedFilenamesToElement).length is 0 and @completionCallback
      @completionCallback(@container[0].outerHTML, @scriptMapping)

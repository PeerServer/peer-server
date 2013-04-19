""" Top-level organizing class for user control over server (ie, setting initial page, UI, etc) 

Right now is just some quick-and-dirty code to get some cool functionality. 
We should think through UI before it gets too messy. 
"""

class window.ServerUserPortal

  constructor: (@portalElem, @fileStore) ->
    @fileStore.registerForEvent("fileStore:fileAdded", @fileAddedCallback)
    @startSelector = $('<select id="start-selector"><option value="default">(default)</option></select>')
    @portalElem.append("Set the landing page: ")
    @portalElem.append(@startSelector)

  # Update the selector so that it has all uploaded HTML files, plus "(default)"
  fileAddedCallback: (data) =>
    filename = data.name
    # Append if it is an html file not already on the list.
    if (filename.slice(-5) is ".html" and not @selectorContainsOption(@startSelector, filename))
      @startSelector.append('<option value="' + filename + '">' + filename + '</option>')

  getLandingPage: =>
    landing = @startSelector.find(":selected").val()
    console.log "landing page:" + landing
    if landing is "default"
      return "<h2>Welcome page</h2><p>Good job.</p>"
    return @fileStore.getFileContents(landing)

  selectorContainsOption: (selector, option) =>
    return (selector.find("option[value='" + option + "']").length > 0)
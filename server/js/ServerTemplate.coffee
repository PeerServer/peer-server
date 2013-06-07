''' Loads a template from the name of a zip that lives on the server.
'''

class window.ServerTemplateModel extends Backbone.Model

  initialize: (options) ->
    @handleZipFcn = options.handleZipFcn
    @templateUri = options.templateUri
    if @templateUri isnt "blank"
      @handleTemplate()

  handleTemplate: =>
    # Use XML so that zip encodings don't break. 
    request = new XMLHttpRequest()
    request.open("GET", "/template/" + @templateUri, true)
    request.responseType = 'blob'

    _this = @
    request.onreadystatechange = (evt) ->
      if this.readyState is 4 and this.status is 200
        _this.handleZipFcn(this.response)
      if this.readyState is 4 and this.status is 404
        console.error "Error loading template."
    request.send()

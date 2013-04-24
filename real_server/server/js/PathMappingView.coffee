class window.PathMappingView extends Backbone.View
  className: "tab-pane active"
  
  initialize: ->
    _.bindAll @
    
  render: =>
    @el.id = @model.get("path")
    template = Handlebars.compile($("#tab-pane-template").html())
    $(@el).html(template)
    new CodeEditor(ace.edit($(@el).find(".file-contents")))
    return @

class window.PathMappingView extends Backbone.View
  className: "tab-pane active"
  
  initialize: ->
    _.bindAll @
    

  render: =>
    @el.id = @model.get("path")
    $(@el).html """
                <p>I'm in Section #{@model.get("path")}.</p>
                """
    return @

    

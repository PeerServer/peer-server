class window.ServerFileView extends Backbone.View

  initialize: ->

  render: =>
    template = Handlebars.compile($("#file-view-template").html())
    $(@el).html(template)
    
    fileContents = $(@el).find(".file-contents")
    fileContents.text(@model.get("contents"))
    @aceEditor = ace.edit(fileContents[0])
    @aceEditor.setTheme("ace/theme/tomorrow_night_eighties")
    @aceEditor.getSession().setMode("ace/mode/html")
    @aceEditor.setFontSize("12px")

    @aceEditor.on("change", @updateContents)
    
    return @

  updateContents: =>
    @model.set("contents", @aceEditor.getValue())

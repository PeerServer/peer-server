class window.RouteView extends Backbone.View
  initialize: (options) ->
    @tmplRoute = Handlebars.compile($("#route-template").html())

  events:
    "keyup .path": "eventPathChange"
    "keyup .name": "eventNameChange"

  render: =>
    $el = $(@el)
    $el.html(@tmplRoute(
      name: @model.get("name"),
      path: @model.get("routePath"),
      functionParams: "abc, 123"))

    $code = @$(".code")
    $name = @$(".name")
    $path = @$(".path")

    # Set up ACE editor
    $code.text(@model.get("routeCode"))
    @aceEditor = ace.edit($code[0])
    @aceEditor.setTheme("ace/theme/tomorrow_night_eighties")
    @aceEditor.setFontSize("12px")
    @aceEditor.getSession().setMode("ace/mode/javascript")

    @aceEditor.on("change", @updateContents)

    return @

  updateContents: =>
    @model.save("routeCode", @aceEditor.getValue())

  eventPathChange: (event) =>
    target = $(event.currentTarget)
    @model.save("routePath", target.val())

  eventNameChange: (event) =>
    target = $(event.currentTarget)
    @model.save("name", target.val())

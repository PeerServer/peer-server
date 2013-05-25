class window.RouteView extends Backbone.View
  initialize: (options) ->
    @tmplRoute = Handlebars.compile($("#route-template").html())

    @model.on "change:name", (route) =>
      $($(@el).find(".route-fcn-name")).html(route.get("name"))  # This is hacky but keeps it up to date
    @model.on("change:paramNames", @handleRoutePathChange)


  events:
    "keyup .path": "eventPathChange"
    "keyup .name": "eventNameChange"

  handleRoutePathChange: (route) =>
    $($(@el).find(".route-fcn-params")).html(@paramNamesToString(route.get("paramNames")))

  paramNamesToString: (paramNames) =>
    if paramNames.length == 0
      return "params"
    return paramNames.join(", ") + ", params"

  render: =>
    $el = $(@el)
    $el.html @tmplRoute
      name: @model.get("name"),
      path: @model.get("routePath"),
      functionParams: @paramNamesToString([])

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

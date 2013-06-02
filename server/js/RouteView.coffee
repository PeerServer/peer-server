class window.RouteView extends Backbone.View
  initialize: (options) ->
    @tmplRoute = Handlebars.templates["route"]
    @tmplFunctionSignature = Handlebars.templates["route-function-signature"]

    @model.on("change:paramNames", @renderFunctionSignature)
    @model.on("change", @renderValidationResult)
    @model.on("destroy", @onDestroy)

    @initProductionRouteEvents()
    @model.on("change:productionVersion", @initProductionRouteEvents, @)

  events:
    "keyup .path": "eventPathChange"
    "keyup .name": "eventNameChange"
    "remove": "onDestroy"

  initProductionRouteEvents: =>
    @productionRoute = @model.get("productionVersion")
    if @productionRoute
      @productionRoute.on("change:errorMessage", @updateErrorMessage)

  paramNamesToString: (paramNames) =>
    if paramNames.length == 0
      return "params"
    return paramNames.join(", ") + ", params"

  render: =>
    $el = $(@el)

    errorMessage = ""
    if @productionRoute
      errorMessage = @productionRoute.get("errorMessage")

    $el.html @tmplRoute
      name: @model.get("name"),
      path: @model.get("routePath"),
      functionParams: @paramNamesToString([]),
      errorMessage: errorMessage

    @code = @$(".code")
    @path = @$(".path")
    @functionSignature = @$(".function-signature")

    @aceEditor = @createEditor(@code)
    @aceEditor.getSession().setValue(@model.get("routeCode"))
    @aceEditor.on("change", @updateContents)

    @renderFunctionSignature()

    @name.tipsy(fallback: "Invalid name", trigger: "manual")
    @path.tipsy(fallback: "Invalid route path", trigger: "manual")

    return @

  focus: =>
    @name.focus()

  renderFunctionSignature: =>
    @functionSignature.html(@tmplFunctionSignature(
      name: @model.get("name"),
      parameterString: @paramNamesToString(@model.get("paramNames"))))
    @name = @$(".name")

  createEditor: (elem) =>
    editor = ace.edit(elem[0])
    editor.setTheme("ace/theme/tomorrow_night_eighties")
    editor.setFontSize("12px")
    editor.getSession().setMode("ace/mode/javascript")
    return editor

  updateErrorMessage: =>
    if @productionRoute.get("errorMessage")
      $(@el).find(".error-message").html(@productionRoute.get("errorMessage"))

  updateContents: =>
    @model.save("routeCode", @aceEditor.getValue())

  eventPathChange: (event) =>
    target = $(event.currentTarget)
    @model.save("routePath", target.val())

  eventNameChange: (event) =>
    target = $(event.currentTarget)
    @model.save("name", target.val())

  renderValidationResult: (model, error) =>
    @model.isValid()
    error = @model.validationError

    if error and error.name
      @name.tipsy("show")
    else
      @name.tipsy("hide")

    if error and error.routePath
      @path.tipsy("show")
    else
      @path.tipsy("hide")

  onDestroy: =>
    @aceEditor.destroy()
    $('.tipsy').remove()
    @model.off(null, null, @)

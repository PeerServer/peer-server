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

  @nameErrorText: "Invalid name"
  @pathErrorText: "Invalid route path"

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

    $el.html @tmplRoute
      name: @model.get("name"),
      path: @model.get("routePath"),
      functionParams: @paramNamesToString([])

    @updateErrorMessage()

    @code = @$(".code")
    @path = @$(".path")
    @functionSignature = @$(".function-signature")

    @aceEditor = @createEditor(@code)
    @aceEditor.getSession().setValue(@model.get("routeCode"))
    @aceEditor.on("change", @updateContents)

    @renderFunctionSignature()

    @replaceTooltipsy(null, @name, RouteView.nameErrorText)
    @replaceTooltipsy(null, @path, RouteView.pathErrorText)

    return @

  focus: =>
    @name.focus()
    @renderValidationResult()

  renderFunctionSignature: =>
    @functionSignature.html(@tmplFunctionSignature(
      name: @model.get("name"),
      parameterString: @paramNamesToString(@model.get("paramNames"))))

    newName = @$(".name")
    @replaceTooltipsy(@name, newName, RouteView.nameErrorText)
    @name = newName

  createEditor: (elem) =>
    editor = ace.edit(elem[0])
    editor.setTheme("ace/theme/tomorrow_night_eighties")
    editor.setFontSize("12px")
    editor.getSession().setMode("ace/mode/javascript")
    return editor

  updateErrorMessage: =>
    startsWith = (str, start) ->
      return str.slice(0, start.length) is start
    displayWithClass = (errorMessage, className) =>
      $(errorMessage).removeClass("alert-error").removeClass("alert-block").removeClass("alert-success").addClass(className)
    errorMessageContainer = $(@el).find(".error-message-container")
    if @productionRoute and @productionRoute.get("errorMessage")
      errorMessage = errorMessageContainer.find(".error-message")
      message = @productionRoute.get("errorMessage")
      errorMessage.html(message)
      if startsWith(message, "Success: ")
        displayWithClass(errorMessageContainer, "alert-success") 
      else if startsWith(message, "Note: ")
        displayWithClass(errorMessageContainer, "alert-block")
      else 
        displayWithClass(errorMessageContainer, "alert-error")
      errorMessageContainer.show()
    else
      errorMessageContainer.hide()


  updateContents: =>
    @model.save("routeCode", @aceEditor.getValue())

  eventPathChange: (event) =>
    target = $(event.currentTarget)
    @model.save("routePath", target.val())
    @renderValidationResult()

  eventNameChange: (event) =>
    target = $(event.currentTarget)
    @model.save("name", target.val())
    @renderValidationResult()

  renderValidationResult: (model, error) =>
    @model.isValid()
    error = @model.validationError

    if $(@name).data('tooltipsy')
      if error and error.name
        $(@name).data('tooltipsy').show()
      else
        $(@name).data('tooltipsy').hide()

    if $(@path).data('tooltipsy')
      if error and error.routePath
        $(@path).data('tooltipsy').show()
      else
        $(@path).data('tooltipsy').hide()

  onDestroy: =>
    @aceEditor.destroy()
    $(@name).data('tooltipsy').destroy()
    $(@path).data('tooltipsy').destroy()
    @model.off(null, null, @)


  replaceTooltipsy: (oldTooltipsyEl, newTooltipsyEl, text) =>
    if oldTooltipsyEl
      $(oldTooltipsyEl).data('tooltipsy').destroy()

    $(newTooltipsyEl).tooltipsy({
      content: text,
      hideEvent: "",
      showEvent: "",
      offset: [0, 1]
    })

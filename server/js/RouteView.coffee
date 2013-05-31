class window.RouteView extends Backbone.View
  initialize: (options) ->
    @tmplRoute = Handlebars.compile($("#route-template").html())
    @tmplFunctionSignature = Handlebars.compile(
      $("#route-function-signature-template").html())

    @model.on("change", @renderValidationResult)
    @model.on("change:paramNames", @renderFunctionSignature)

  events:
    "keyup .path": "eventPathChange"
    "keyup .name": "eventNameChange"

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

  adjustHeights: =>
    $el = $(@el)

    @$(".function").outerHeight(
      $el.height() - @$(".route-path").outerHeight(true))

    padding = @$(".function").innerHeight() - @$(".function").height()
    codeHeight = @$(".function").height() - padding
    codeHeight -= @functionSignature.outerHeight(true)
    codeHeight -= @$(".function-close").outerHeight(true)
    codeHeight -= @$(".route-help").outerHeight(true)
    @code.outerHeight(codeHeight)

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


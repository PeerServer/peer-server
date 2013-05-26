class window.RouteView extends Backbone.View
  initialize: (options) ->
    @tmplRoute = Handlebars.compile($("#route-template").html())
    @model.on("change", @renderValidationResult)
    @model.on("change:paramNames", @renderFunctionSignatureText)

  events:
    "keyup .path": "eventPathChange"
    "keyup .name": "eventNameChange"
    "keypress .code textarea": "eventACEKeydown"
    # "keydown  .code textarea": "eventACEKeydown"

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
    @name = @$(".name")
    @path = @$(".path")
    @functionSignature = @$(".function-signature")
    @functionClose = @$(".function-close")

    # @functionSignature.height(16 * 4)
    # @functionClose.height(16 * 2)
    @code.height(100)

    @aceEditor = @createEditor(@code)
    @aceEditor.getSession().setValue(@model.get("routeCode"))
    # @aceEditor.on("change", @updateContents)

    # @functionSignatureEditor = @createEditor(@functionSignature)
    # @renderFunctionSignatureText()
    # @functionSignatureEditor.setReadOnly(true)
    # @functionSignatureEditor.on("changeSelectionStyle", () ->
    #   console.log arguments)

    # functionCloseEditor = @createEditor(@functionClose)
    # functionCloseEditor.getSession().setValue("\n}")
    # functionCloseEditor.setReadOnly(true)

    @name.tipsy(fallback: "Invalid name", trigger: "manual")
    @path.tipsy(fallback: "Invalid route path", trigger: "manual")

    return @

  renderFunctionSignatureText: =>
    @functionSignatureEditor.getSession().setValue(
      "// This is the function signature.\n" +
      "function " + @model.get("name") + "(" +
      @paramNamesToString(@model.get("paramNames")) + ") {\n" +
      "    // Put your code below...\n")

  createEditor: (elem) =>
    editor = ace.edit(elem[0])
    editor.setTheme("ace/theme/tomorrow_night_eighties")
    editor.setFontSize("12px")
    editor.getSession().setMode("ace/mode/javascript")
    return editor

  updateContents: =>
    @model.save("routeCode", @aceEditor.getValue())
    console.log arguments

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

  eventACEKeydown: (event) =>
    position = @aceEditor.getCursorPosition()
    numRows = @aceEditor.session.getLength()
    console.log position, numRows, event.which

    if position.row is 0 or
    position.row is numRows - 1 or
    (position.row is 1 and position.column is 0 and event.which is 8)
      @aceEditor.setReadOnly(true)
      event.preventDefault()
      event.stopPropagation()
      return false
    else
      @aceEditor.setReadOnly(false)


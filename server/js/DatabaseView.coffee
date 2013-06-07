class window.DatabaseView extends Backbone.View
  el: "#database-view"

  events:
    "click .run-query": "runQuery"

  initialize: (options)->
    @userDatabase = options.userDatabase
    @tmplUserDatabase = Handlebars.templates["user-database"]
    @userDatabase.on("initLocalStorage", @render)
    @render()

  render: =>
    json = @userDatabase.toString(true)
    $(@el).html(@tmplUserDatabase(json: json))

    @queryEditor = @$(".query-editor")
    @output = @$(".output")

    hljs.highlightBlock(@output[0], false, false)

    # Set up ACE editor
    fileContents = @queryEditor
    @aceEditor = ace.edit(fileContents[0])
    @aceEditor.setTheme("ace/theme/tomorrow_night_eighties")
    @aceEditor.setFontSize("12px")
    @aceEditor.getSession().setMode("ace/mode/javascript")

    return @

  runQuery: =>
    query = @aceEditor.getValue()
    if not /return/.test(query)
        query += "return database().get();"
    result = @userDatabase.runQuery(query)
    json = JSON.stringify(result, null, 4)
    @output.text(json)
    hljs.highlightBlock(@output[0], false, false)


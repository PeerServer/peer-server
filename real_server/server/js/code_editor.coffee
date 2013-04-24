""" Wrapper for an ACE code editor. """

class window.CodeEditor

  constructor: (@aceEditor) ->
    @aceEditor.setTheme("ace/theme/tomorrow_night_eighties")
    @aceEditor.getSession().setMode("ace/mode/html");
    @aceEditor.setFontSize("16px");

  setCodeContents: (code) ->
      @aceEditor.setValue(code)
      @aceEditor.navigateFileStart()

  getCodeContents: ->
      return @aceEditor.getValue()
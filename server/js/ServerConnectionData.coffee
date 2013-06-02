''' Backend and view for data surrounding the connections to the server. 

Tracks the count.
'''

class window.ServerConnectionDataModel extends Backbone.Model

  defaults:
    count: 0

class window.ServerConnectionDataView extends Backbone.View
  initialize: (options) ->
    @el = $(@el)
    @dataEl = @el.find(".server-connection-data")
    @dataEl.html(@model.get("count"))  # Initial display.
    @model.on "change:count", (newCount) =>
      @dataEl.html(@model.get("count"))



''' Handles all frontend setup for UI.
'''

class window.AppView extends Backbone.View
  el: "#client-server"

  initialize: ->
    @serverFileCollectionView = new ServerFileCollectionView(collection: @collection, isEditable: false)

    @editServerButton = @$(".edit-server")
    @editServerDoneButton = @$(".edit-server-done")

  events:
    "click .edit-server": "toggleIsEditable"
    "click .edit-server-done": "doneEditing"

  toggleIsEditable: =>
    @editServerButton.toggle()
    @editServerDoneButton.toggle()
    @serverFileCollectionView.toggleIsEditable()

  doneEditing: =>
    @collection.createProductionVersion()
    @toggleIsEditable()


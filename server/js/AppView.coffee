''' Handles all frontend setup for UI.
'''

class window.AppView extends Backbone.View
  el: "#client-server"

  initialize: ->
    @serverFileCollectionView = new ServerFileCollectionView(collection: @collection)

  setClientBrowserLink: (link) =>
    clientBrowserLink = $(".browser-link")
    clientBrowserLink.attr('href', link)
    clientBrowserLink.html(link)
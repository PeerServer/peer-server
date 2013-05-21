''' Handles all frontend setup for UI.
'''

class window.AppView extends Backbone.View
  el: "#client-server"

  initialize: (options)->
    @serverFileCollectionView = new ServerFileCollectionView(collection: options.serverFileCollection)
    @routeCollectionView = new RouteCollectionView(collection: options.routeCollection)

  setClientBrowserLink: (link) =>
    clientBrowserLink = $(".browser-link")
    clientBrowserLink.attr('href', link)
    clientBrowserLink.html(link) 
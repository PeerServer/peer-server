''' Handles all frontend setup for UI.
'''

class window.AppView extends Backbone.View
  el: "#client-server"

  initialize: (options)->
    @serverFileCollectionView = new ServerFileCollectionView(collection: options.serverFileCollection)

    @routeCollectionView = new RouteCollectionView(collection: options.routeCollection)

    @on("setServerID", @setClientBrowserLink)

  setClientBrowserLink: (serverID) =>
    link = window.location.origin + "/connect/" + serverID + "/"
    clientBrowserLink = $(".browser-link")
    clientBrowserLink.attr('href', link)
    clientBrowserLink.html(link)

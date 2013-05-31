''' Handles all frontend setup for UI.
'''

class window.AppView extends Backbone.View
  el: "#client-server"

  initialize: (options)->
    @clientBrowserLink = $(".navbar .browse")
    @archiveButton = $(".navbar .archive")

    @serverFileCollectionView = new ClientServerCollectionView(
      serverFileCollection: options.serverFileCollection,
      routeCollection: options.routeCollection,
      userDatabase: options.userDatabase)

    @archiver = new ClientServerArchiver(
      serverFileCollection: options.serverFileCollection,
      routeCollection: options.routeCollection,
      userDatabase: options.userDatabase,
      button: @archiveButton)

    @on("setServerID", @setClientBrowserLink)

  setClientBrowserLink: (serverID) =>
    link = window.location.origin + "/connect/" + serverID + "/"
    @clientBrowserLink.attr("href", link)
    

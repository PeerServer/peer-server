''' Handles all frontend setup for UI.
'''

class window.AppView extends Backbone.View
  el: "#client-server"

  initialize: (options)->
    @serverFileCollection = options.serverFileCollection
    @routeCollection = options.routeCollection
    @userDatabase = options.userDatabase

    @clientBrowserLink = $(".navbar .browse")
    @archiveButton = $(".navbar .archive")
    @editLink = $(".navbar .edit")
    @databaseLink = $(".navbar .database")

    @tmplEditPage = Handlebars.templates["edit-page"]
    @tmplDatabasePage = Handlebars.templates["database-page"]

    @on("setServerID", @setClientBrowserLink)

    @editLink.click(@goToEditPage)
    @databaseLink.click(@goToDatabasePage)

    # @goToEditPage()
    #TODO
    @goToDatabasePage()

  setClientBrowserLink: (serverID) =>
    link = window.location.origin + "/connect/" + serverID + "/"
    @clientBrowserLink.attr("href", link)

  goToEditPage: =>
    $(@el).html(@tmplEditPage)

    @serverFileCollectionView = new ClientServerCollectionView(
      serverFileCollection: @serverFileCollection,
      routeCollection: @routeCollection,
      userDatabase: @userDatabase)

    @archiver = new ClientServerArchiver(
      serverFileCollection: @serverFileCollection,
      routeCollection: @routeCollection,
      userDatabase: @userDatabase,
      button: @archiveButton)

  goToDatabasePage: =>
    $(@el).html(@tmplDatabasePage())

    @databaseView = new DatabaseView(userDatabase: @userDatabase)


    

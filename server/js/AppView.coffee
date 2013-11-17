''' Handles all frontend setup for UI.
'''

class window.AppView extends Backbone.View
  el: "#client-server"

  initialize: (options)->
    @serverFileCollection = options.serverFileCollection
    @routeCollection = options.routeCollection
    @userDatabase = options.userDatabase
    @serverAge = new ServerAge($(".server-age-wrapper"))
    @connectionDataView = new ServerConnectionDataView({el: $(".server-connection-data-wrapper"), model: new ServerConnectionDataModel()})

    # Templates
    @tmplEditPage = Handlebars.templates["edit-page"]
    @tmplDatabasePage = Handlebars.templates["database-page"]
    @tmplTopbarButtons = Handlebars.templates["topbar-buttons"]
    @tmplServerIDMessage = Handlebars.templates["server-id-message"]

    # Routes
    @routeMap =
      "edit": @goToEditPage
      "database": @goToDatabasePage
    @routeDefault = "edit"
    @routeCurrent = ""

    # Events
    @on("setServerID", @setClientBrowserLink)
    @on("onUnavailableID", @goToUnavailableIDPage)
    @on("onInvalidID", @goToInvalidIDPage)

    $(window).on("hashchange", () => @goToPage())

  setClientBrowserLink: (serverID) =>
    @serverID = serverID
    @goToPage()
    link = window.location.origin + "/connect/" + serverID + "/"
    @clientBrowserLink.attr("href", link)

  updateConnectionCount: (count) =>
    @connectionDataView.model.set("count", count)


  handleZipFile: (file) =>
    reader = new FileReader()
    reader.onload = (evt) =>
      new ClientServerUnarchiver(
        serverFileCollection: @serverFileCollection,
        routeCollection: @routeCollection,
        userDatabase: @userDatabase,
        contents: evt.target.result)
    reader.readAsArrayBuffer(file)


  renderTopbarButtons: =>
    $(".topbar-buttons").remove()
    $(".topbar").append(@tmplTopbarButtons)

    @clientBrowserLink = $(".navbar .browse")
    @archiveButton = $(".navbar .archive")

  goToPage: (slug) =>
    if slug
      location.hash = "#" + slug
    else
      slug = location.hash.replace("#", "")

    if not @routeMap[slug]
      slug = @routeDefault

    return if slug is @routeCurrent
    @routeCurrent = slug

    @routeMap[slug]()

  goToEditPage: =>
    @renderTopbarButtons()
    $(@el).html(@tmplEditPage)

    @serverFileCollectionView = new ClientServerCollectionView(
      serverFileCollection: @serverFileCollection,
      routeCollection: @routeCollection,
      userDatabase: @userDatabase,
      handleZipFcn: @handleZipFile)

    @archiver = new ClientServerArchiver(
      serverName: @serverID,
      serverFileCollection: @serverFileCollection,
      routeCollection: @routeCollection,
      userDatabase: @userDatabase,
      button: @archiveButton)

  goToDatabasePage: =>
    @renderTopbarButtons()
    $(@el).html(@tmplDatabasePage())

    @databaseView = new DatabaseView(userDatabase: @userDatabase)

  goToUnavailableIDPage: (desiredServerID) =>
    # TODO: The redirect currently drops the template argument -- the redirection
    # should pass along the original template URL parameter.
    $(".topbar-buttons").remove()
    $(@el).html(@tmplServerIDMessage(
      message: "\"" + desiredServerID + "\" is unavailable.",
      alternativeServerID: @getAlternativeServerID()))

  goToInvalidIDPage: (desiredServerID) =>
    $(".topbar-buttons").remove()
    $(@el).html(@tmplServerIDMessage(
      message: "\"" + desiredServerID + "\" is an invalid server name.",
      alternativeServerID: @getAlternativeServerID()))

  getAlternativeServerID: =>
    randomIndex = Math.floor(Math.random() * AppView.listOfAnimals.length)
    return AppView.listOfAnimals[randomIndex]

  @listOfAnimals: [
    "aardvark",
    "albatross",
    "alligator",
    "alpaca",
    "ant",
    "anteater",
    "antelope",
    "ape",
    "donkey",
    "badger",
    "bat",
    "bear",
    "beaver",
    "bee",
    "bison",
    "buffalo",
    "butterfly",
    "camel",
    "caribou",
    "cat",
    "caterpillar",
    "cattle",
    "cheetah",
    "chicken",
    "chinchilla",
    "clam",
    "cobra",
    "coyote",
    "crab",
    "crane",
    "crocodile",
    "crow",
    "deer",
    "dinosaur",
    "dog",
    "dogfish",
    "dolphin",
    "dove",
    "dragonfly",
    "duck",
    "eagle",
    "eel",
    "elephant",
    "elk",
    "falcon",
    "finch",
    "fish",
    "flamingo",
    "fly",
    "fox",
    "frog",
    "gazelle",
    "gerbil",
    "panda",
    "giraffe",
    "gnat",
    "goat",
    "goose",
    "goldfinch",
    "goldfish",
    "grasshopper",
    "hamster",
    "hare",
    "hawk",
    "hedgehog",
    "heron",
    "hornet",
    "hippo",
    "horse",
    "hummingbird",
    "hyena",
    "jaguar",
    "jay",
    "jellyfish",
    "kangaroo",
    "lark",
    "lemur",
    "lion",
    "leopard",
    "llama",
    "lyrebird",
    "magpie",
    "manatee",
    "meerkat",
    "mole",
    "monkey",
    "marten",
    "moose",
    "mouse",
    "newt",
    "narwhal",
    "mule",
    "nightingale",
    "octopus",
    "otter",
    "owl",
    "oyster",
    "panther",
    "parrot",
    "partridge",
    "pelican",
    "penguin",
    "pig",
    "pigeon",
    "pony",
    "porcupine",
    "porpoise",
    "quail",
    "rabbit",
    "raccoon",
    "ram",
    "rat",
    "raven",
    "reindeer",
    "salmon",
    "salamander",
    "scorpion",
    "seal",
    "shark",
    "sheep",
    "shrimp",
    "snail",
    "snake",
    "squid",
    "squirrel",
    "starling",
    "swallow",
    "swan",
    "tiger",
    "turkey",
    "trout",
    "turtle",
    "vulture",
    "whale",
    "wolf"
    "wolverine",
    "woodpecker",
    "yak",
    "zebra"
  ]

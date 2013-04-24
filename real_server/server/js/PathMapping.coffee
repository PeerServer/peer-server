class window.PathMapping extends Backbone.Model
  initialize: ->
    _.bindAll(@)

  defaults:
    isLandingPage: false
    path: "index"
    files: ["page.html", "style.css", "image.png"]

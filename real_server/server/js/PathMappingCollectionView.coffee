class window.PathMappingCollectionView extends Backbone.View
  el: "#path-mapping-collection-view"

  initialize: ->
    _.bindAll @

    @collection = new PathMappingCollection()
    @collection.bind("add", @appendPathMapping)
    @collection.bind("change:path", @handlePathChange)
    @collection.bind("change:isLandingPage", @handleIsLandingPageChange)
    
    @render()
    @addDefaultFile()

  addDefaultFile: =>
    # TODO fix this up nicely so it is indicated on the frontend as the landing page at first.
    defaultFile = "<h2>Welcome page</h2><p>Good job.</p>"
    @addPathMapping()
    window.fileStore.addFile("default.html", defaultFile.length, "text/html", defaultFile)

  getLandingPage: ->
    landing = @collection.find (pathMapping) ->
      return pathMapping.get("isLandingPage") == true
    if landing
      path = landing.get("path")
    else
      # return {"contents": "", "url":"default.html"}
      path = "default.html"
    contents = window.fileStore.getFileContents(path)
    return {"fileContents": contents, "filename": path, "type":"text/html"}

  render: ->
    $(@el).html """
                <ul class="nav nav-tabs">
                  <li class="add-button-li"><a href="#"><i>+ Add Path Mapping</i></a></li>
                </ul>
                
                <div class="tab-content"></div>
                """
    return @
    
  handlePathChange: (pathMapping, path) ->
    elA = @.$(".nav-tabs a[href=##{pathMapping.cid}]")
    console.log(elA, pathMapping, path)
    elA.text(path)

  handleIsLandingPageChange: (pathMapping, isLandingPage) ->
    if not isLandingPage
      elA = @.$(".nav-tabs a[href=##{pathMapping.cid}]")
      elA.find(".icon-ok").remove()
      return
    
    @collection.each (otherPathMapping) ->
      if otherPathMapping != pathMapping
        otherPathMapping.set("isLandingPage", false)
        elA = @.$(".nav-tabs a[href=##{otherPathMapping.cid}]")
        elA.find(".icon-ok").remove()
        console.log(elA.find(".icon-ok"))

    elA = @.$(".nav-tabs a[href=##{pathMapping.cid}]")
    elA.prepend('<i class="icon-ok"></i>')
    
  addPathMapping: ->
    pathMapping = new PathMapping()
    @collection.add(pathMapping)

  appendPathMapping: (pathMapping) ->
    pathMappingView = new PathMappingView(model: pathMapping)
    console.log("appending", pathMappingView)

    $(".nav-tabs li").removeClass("active")
    $(".tab-pane").removeClass("active")

    navTabEl = $("""
              <li class='active'>
                <a data-toggle='tab' href='##{pathMapping.cid}'>New Path</a>
              </li>
              """)
    $(".add-button-li").before(navTabEl)
    $(".tab-content").append(pathMappingView.render().el)

  events:
    "click .add-button-li a": "addPathMapping"

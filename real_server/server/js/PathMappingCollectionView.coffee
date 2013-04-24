class window.PathMappingCollectionView extends Backbone.View
  el: "#path-mapping-collection-view"

  initialize: ->
    _.bindAll @

    @collection = new PathMappingCollection()
    @collection.bind("add", @appendPathMapping)
    @collection.bind("change:path", @handlePathChange)
    @collection.bind("change:isLandingPage", @handleIsLandingPageChange)
    
    @render()

  getLandingPage: ->
    landing = @collection.find (pathMapping) ->
      return pathMapping.get("isLandingPage") == true
    console.log "landing page:" + landing
    if not landing
      return "<h2>Welcome page</h2><p>Good job.</p>"
    landing = landing.get("path")
    return window.fileStore.getFileContents(landing)

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

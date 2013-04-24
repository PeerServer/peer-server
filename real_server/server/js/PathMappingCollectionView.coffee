class window.PathMappingCollectionView extends Backbone.View
  el: "#path-mapping-collection-view"

  initialize: ->
    _.bindAll @

    @collection = new PathMappingCollection()
    @collection.bind("add", @appendPathMapping)
    
    @uninitializedPathMappingView = null

    @render()

  render: ->
    $(@el).html """
                <ul class="nav nav-tabs">
                  <li class="add-button-li"><a href="#"><i>+ Add Path Mapping</i></a></li>
                </ul>
                
                <div class="tab-content"></div>
                """
    return @
    
  addPathMapping: ->
    pathMapping = new PathMapping()
    @collection.add(pathMapping)

  appendPathMapping: (pathMapping) ->
    @uninitializedPathMappingView = new PathMappingView(model: pathMapping)

    $(".nav-tabs li").removeClass("active")
    $(".tab-pane").removeClass("active")

    navTabEl = $("""
              <li class='active'>
                <input type="text" placeholder="Type something…">
              </li>
              """)
    navTabEl.find("a").tab("show")
    $(".add-button-li").before(navTabEl)
    navTabEl.find("input").focus()

  handleNavTabInputBlur: (event) ->
    input = $(event.target)
    @uninitializedPathMappingView.model.set("path", input.val())
    path = @uninitializedPathMappingView.model.get("path")
    input.replaceWith("<a data-toggle='tab' href='##{path}'>#{path}</a>")
    $(".tab-content").append(@uninitializedPathMappingView.render().el)
    @uninitializedPathMappingView = null

  events:
    "click .add-button-li a": "addPathMapping"
    "blur .nav-tabs input": "handleNavTabInputBlur"

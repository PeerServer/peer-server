''' 
  Display and organization of the user-uploaded file collection. 
  Edit/Done modes for saving.
'''


class window.RouteCollectionView extends Backbone.View
  el: "#router-view"

  initialize: (options) ->
    $("#router-view").append("Routes:") 
    @tmplRouteListItem = Handlebars.compile($("#route-list-item-template").html())

    @addAll()
    @collection.bind("add", @addOne)
    @collection.bind("reset", @addAll)
    @collection.bind("change", @handleFileChanged)
    @collection.add(new Route(routePath: "/sth", routeCode: "(function() {return 'sth'})()", isRequired: true))


  addAll: =>
    @collection.each(@addOne)

  addOne: (route) =>
    return if route.get("isProductionVersion")
    listEl = @tmplRouteListItem(cid: route.cid, routePath:route.get("routePath"), routeCode: route.get("routeCode"))
    @appendItemToRouteList(route, listEl)

  # --- HELPER METHODS ---
  
  appendItemToRouteList: (route, listEl) =>
    $("#router-view").append(listEl)
    return null

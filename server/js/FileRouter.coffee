
# TODO: add parameters as part of scope
# TODO: allow route path specification with parameters (treat parameters like flask)
# TODO: allow route path specification with matching the param in the route name, possibly wild cards

class window.Route extends Backbone.Model
  defaults:
    routePath: ""
    routeCode: ""
    options: {}
    isRequired: false
    isProductionVersion: false

  initialize: ->
    # TODO


class window.RouteCollection extends Backbone.Collection
  model: Route
  
  initialize: ->
    indexRoute = new Route(routePath: "/test", routeCode: "'test page: ' + params.q", isRequired: true)
    @add(indexRoute)

  comparator: (route) =>
    return route.get("routePath")

  # TODO also match params and stuff
  hasRoute: (routePath) =>
    console.log "route path: " + routePath
    return @findWhere(routePath: routePath)

  getRouteCode: (routePath) =>
    return @findWhere(routePath: routePath).get("routeCode")
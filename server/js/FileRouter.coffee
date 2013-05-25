
# TODO: add parameters as part of scope
# TODO: allow route path specification with parameters (treat parameters like flask)
# TODO: allow route path specification with matching the param in the route name, possibly wild cards

class window.Route extends Backbone.Model
  defaults:
    name: ""
    routePath: ""
    routeCode: ""
    options: {}
    isProductionVersion: false
    hasBeenEdited: false

  initialize: ->
    # TODO


class window.RouteCollection extends Backbone.Collection
  model: Route

  localStorage: new Backbone.LocalStorage("RouteCollection")
  
  initialize: ->
    @fetch()

  comparator: (route) =>
    return route.get("routePath")

  # TODO also match params and stuff
  hasRoute: (routePath) =>
    console.log "route path: " + routePath
    return @findWhere(routePath: routePath, isProductionVersion: true)

  getRouteCode: (routePath) =>
    return @findWhere(routePath: routePath).get("routeCode")

  createProductionVersion: =>
    productionFiles = @where(isProductionVersion: true)
    _.each productionFiles, (route) =>
      route.destroy()

    developmentFiles = @where(isProductionVersion: false)
    _.each developmentFiles, (route) =>
      attrs = _.clone(route.attributes)
      attrs.id = null
      copy = new Route(attrs)
      copy.set("isProductionVersion", true)
      @add(copy)
      copy.save()


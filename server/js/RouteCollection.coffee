class window.RouteCollection extends Backbone.Collection
  model: Route
  
  initialize: (options) ->

  initLocalStorage: (namespace) =>
    @localStorage = new Backbone.LocalStorage(namespace + "-RouteCollection")
    @fetch()
    @initDefaultRoute(true)  # Add a default production route if needed 
    @initDefaultRoute(false)  # Add a default development route if needed

  initDefaultRoute: (desiredVersion) =>
    existing = @find (route) =>
      return route.get("isProductionVersion") is desiredVersion and "/index".match(route.pathRegex) isnt null
    return if existing
    route = new Route(
      name: "default",
      routePath: "/index",
      errorMessage: "Note: Path has not yet been executed.",
      routeCode: "return static_file('index.html')  // Change if desired",
      isProductionVersion: desiredVersion)
    @add(route)
    route.save()

  comparator: (route) =>
    return route.get("routePath")

  findRouteForPath: (routePath) =>
    matchedRoute = @find (route) =>
      return route.get("isProductionVersion") and routePath.match(route.pathRegex) isnt null
    return matchedRoute

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
      attrs.productionVersion = null
      productionVersion = new Route(attrs)
      productionVersion.set("isProductionVersion", true)
      @add(productionVersion)
      productionVersion.save()
      route.save("productionVersion", productionVersion)


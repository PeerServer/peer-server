// Generated by CoffeeScript 1.6.2
(function() {
  ' Handles all frontend setup for UI.';
  var _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.AppView = (function(_super) {
    __extends(AppView, _super);

    function AppView() {
      this.goToDatabasePage = __bind(this.goToDatabasePage, this);
      this.goToEditPage = __bind(this.goToEditPage, this);
      this.setClientBrowserLink = __bind(this.setClientBrowserLink, this);      _ref = AppView.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    AppView.prototype.el = "#client-server";

    AppView.prototype.initialize = function(options) {
      this.serverFileCollection = options.serverFileCollection;
      this.routeCollection = options.routeCollection;
      this.userDatabase = options.userDatabase;
      this.clientBrowserLink = $(".navbar .browse");
      this.archiveButton = $(".navbar .archive");
      this.editLink = $(".navbar .edit");
      this.databaseLink = $(".navbar .database");
      this.tmplEditPage = Handlebars.templates["edit-page"];
      this.tmplDatabasePage = Handlebars.templates["database-page"];
      this.on("setServerID", this.setClientBrowserLink);
      this.editLink.click(this.goToEditPage);
      this.databaseLink.click(this.goToDatabasePage);
      return this.goToEditPage();
    };

    AppView.prototype.setClientBrowserLink = function(serverID) {
      var link;

      link = window.location.origin + "/connect/" + serverID + "/";
      return this.clientBrowserLink.attr("href", link);
    };

    AppView.prototype.goToEditPage = function() {
      $(this.el).html(this.tmplEditPage);
      this.serverFileCollectionView = new ClientServerCollectionView({
        serverFileCollection: this.serverFileCollection,
        routeCollection: this.routeCollection,
        userDatabase: this.userDatabase
      });
      return this.archiver = new ClientServerArchiver({
        serverFileCollection: this.serverFileCollection,
        routeCollection: this.routeCollection,
        userDatabase: this.userDatabase,
        button: this.archiveButton
      });
    };

    AppView.prototype.goToDatabasePage = function() {
      $(this.el).html(this.tmplDatabasePage());
      return this.databaseView = new DatabaseView({
        userDatabase: this.userDatabase
      });
    };

    return AppView;

  })(Backbone.View);

}).call(this);

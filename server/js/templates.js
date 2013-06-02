(function() {
  var template = Handlebars.template, templates = Handlebars.templates = Handlebars.templates || {};
templates['database-page'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  


  return "<div id=\"database-view\">\n\n</div>\n";
  });
templates['edit-page'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  


  return "<div id=\"client-server-collection-view\">\n  <div id=\"save-notification-container\">\n    <div id=\"save-notification\">\n      <p>\n        <a href=\"#\" class=\"save-changes\">Click here</a> for your changes to go live.\n      </p>\n    </div>\n  </div>\n  \n\n  <div class=\"left-sidebar-container\">\n    <div class=\"left-sidebar\">\n\n      <ul class=\"nav nav-tabs nav-stacked\">\n\n        <li class=\"dropdown\">\n        <a class=\"dropdown-toggle\" data-toggle=\"dropdown\" href=\"#\">\n          Create <b class=\"caret\"></b>\n        </a>\n        <ul class=\"dropdown-menu create-menu\">\n          <li class=\"html\"><a href=\"#\">HTML</a></li>\n          <li class=\"css\"><a href=\"#\">CSS</a></li>\n          <li class=\"js\"><a href=\"#\">JS</a></li>\n          <li class=\"divider\"></li>\n          <li class=\"dynamic\"><a href=\"#\">Dynamic Path</a></li>\n          <li class=\"template\"><a href=\"#\">Template</a></li>\n        </ul>\n        </li>\n\n        <li class=\"upload-files\"><a href=\"#\">Upload Files</a></li>\n\n        <li class=\"clear-all\"><a href=\"#\">Clear All</a></li>\n\n      </ul>\n\n      <div class=\"file-list-container well\" style=\"padding: 8px 0;\">\n      </div>\n\n    </div>\n  </div>\n\n  <div class=\"main-pane\">\n    <div id=\"file-view-container\"> </div>\n\n    <div id=\"route-view-container\"> </div>\n\n    <div class=\"file-drop well well-large\">\n      <div class=\"file-drop-inner\">\n        <h3>Drop files here</h3>\n      </div>\n    </div>\n  </div>\n\n</div>\n\n";
  });
templates['editable-file-list-item'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<li data-cid=\"";
  if (stack1 = helpers.cid) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.cid; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "\"><input type=\"text\" value=\"";
  if (stack1 = helpers.name) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.name; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "\"></input></li>\n\n";
  return buffer;
  });
templates['file-list-item'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n\n<li data-cid=\"";
  if (stack1 = helpers.cid) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.cid; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "\"><a href=\"#\">";
  if (stack1 = helpers.name) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.name; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "</a></li>\n\n";
  return buffer;
  }

function program3(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n\n<li data-cid=\"";
  if (stack1 = helpers.cid) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.cid; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "\">\n<a href=\"#\">";
  if (stack1 = helpers.name) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.name; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + " <i class=\"delete icon-trash pull-right\"></i></a>\n</li>\n\n  <!-- <li class=\"dropdown\" data&#45;cid=\"";
  if (stack1 = helpers.cid) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.cid; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "\"> -->\n  <!--   <a class=\"dropdown&#45;toggle\" data&#45;toggle=\"dropdown\" href=\"#\"> -->\n  <!--     ";
  if (stack1 = helpers.name) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.name; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + " <b class=\"caret pull&#45;right\" style=\"display: none;\"></b> -->\n  <!--   </a> -->\n  <!--   <ul class=\"dropdown&#45;menu\" style=\"display: none;\"> -->\n  <!--     <li class=\"rename\"><a href=\"#\">Rename</a></li> -->\n  <!--     <li class=\"delete\"><a href=\"#\">Delete</a></li> -->\n  <!--   </ul> -->\n  <!-- </li> -->\n\n";
  return buffer;
  }

  stack1 = helpers['if'].call(depth0, depth0.isRequired, {hash:{},inverse:self.program(3, program3, data),fn:self.program(1, program1, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n\n";
  return buffer;
  });
templates['file-lists'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  


  return "<ul class=\"file-list required nav nav-list\">\n  <li class=\"nav-header\">Required Files</li>\n</ul>\n\n<ul class=\"nav nav-list\">\n  <li class=\"divider\"></li>\n</ul>\n\n<ul class=\"file-list html nav nav-list\">\n  <li class=\"nav-header\">HTML</li>\n</ul>\n\n<ul class=\"file-list css nav nav-list\">\n  <li class=\"nav-header\">CSS</li>\n</ul>\n\n<ul class=\"file-list js nav nav-list\">\n  <li class=\"nav-header\">JS</li>\n</ul>\n\n<ul class=\"file-list img nav nav-list\">\n  <li class=\"nav-header\">Images</li>\n</ul>\n\n<ul class=\"nav nav-list\">\n  <li class=\"divider\"></li>\n</ul>\n\n<ul class=\"file-list dynamic nav nav-list\">\n  <li class=\"nav-header\">Dynamic Files</li>\n</ul>\n\n";
  });
templates['image'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  


  return "<img src=\"\"></img>\n\n";
  });
templates['route-function-signature'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "function <input class=\"name\" type=\"text\" value=\"";
  if (stack1 = helpers.name) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.name; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "\"/> (";
  if (stack1 = helpers.parameterString) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.parameterString; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + ") {\n\n";
  return buffer;
  });
templates['route-list-item'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n  ";
  if (stack1 = helpers.name) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.name; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "\n  ";
  return buffer;
  }

function program3(depth0,data) {
  
  
  return "\n  (No name yet)\n  ";
  }

  buffer += "<li data-cid=\"";
  if (stack1 = helpers.cid) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.cid; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "\">\n<a href=\"#\">\n  ";
  stack1 = helpers['if'].call(depth0, depth0.name, {hash:{},inverse:self.program(3, program3, data),fn:self.program(1, program1, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n\n  <i class=\"delete icon-trash pull-right\"></i>\n</a>\n</li>\n\n";
  return buffer;
  });
templates['route'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n    ";
  if (stack1 = helpers.errorMessage) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.errorMessage; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "\n  ";
  return buffer;
  }

  buffer += "<div class=\"route-help\">\n  <p> <a class=\"showhide\" onclick=\"$('.route-tips').toggle()\" style=\"cursor:pointer\">Show/hide tips on database, templates, sessions, etc.</a>\n  <ul class=\"route-tips\" style=\"display:none\">\n    <li>Database: Use the TaffyDB `database` object to save state. See <a href=\"http://www.taffydb.com/\">TaffyDB</a> for more, or <a href=\"#database\">browse and run sample queries</a>. </li>\n    <li>Templates: Use render_template(\"aTemplate.html\", context) to render the template with the given context (an object mapping names to values). See <a href=\"http://handlebarsjs.com/\">HandlebarsJS</a> for more.</li>\n    <li>Session: Access the current user session with the `session` object and set properties as usual with session.someProperty = someValue.</li>\n    <li>Static files: Use `static_file(\"filename\")` to access the content of static files.</li>\n    <li>Cryptography: Use cryptoRandom(n) to generate a string of integer n random hex bytes. Call hash(str) to securely hash the string str with Sha-2</li>\n  </ul>\n  </p>\n</div>\n\n<div class=\"error-message\">\n  ";
  stack1 = helpers['if'].call(depth0, depth0.errorMessage, {hash:{},inverse:self.noop,fn:self.program(1, program1, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n</div>\n\n<div class=\"well function\" style=\"padding: 8px;\">\n  <div class=\"route-path\">\n    path\n    <span class=\"help\">(Path components entered as \"&lt;someVar&gt;\" will become variables,\n    accessible by your function below.)</span>\n    <br/>\n    <input type=\"text\" placeholder=\"Enter a path mapping\" class=\"path input-xlarge\" value=\"";
  if (stack1 = helpers.path) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.path; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "\">\n  </div>\n  <div class=\"function-signature\"></div>\n\n  <div class=\"code\"></div>\n  \n  <div class=\"function-close\">}</div>\n</div>\n\n";
  return buffer;
  });
templates['server-id-message'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div id=\"server-id-message\">\n\n  <div class=\"sad-face\">:(</div>\n\n  <div class=\"message\">\n\n    <p>";
  if (stack1 = helpers.message) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.message; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "</p>\n\n    <p>\n      Would you like to try\n      <a href=\"/server/";
  if (stack1 = helpers.alternativeServerID) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.alternativeServerID; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "\">";
  if (stack1 = helpers.alternativeServerID) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.alternativeServerID; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "</a>\n      instead?\n    </p>\n\n  </div>\n</div>\n";
  return buffer;
  });
templates['source-code'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  


  return "<div class=\"file-contents\"></div>\n\n";
  });
templates['topbar-buttons'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  


  return "<ul class=\"topbar-buttons nav pull-right\">\n  <li><a class=\"edit\" href=\"#\">Edit</a></li>\n  <li><a class=\"browse\" target=\"_blank\">Browse</a></li>\n  <li><a>Help</a></li>\n  <li><a>Settings</a></li>\n  <li><a class=\"database\" href=\"#\">Database</a></li>\n  <li><a class=\"archive\" href=\"#\">Download Website (ZIP)</a></li>\n</ul>\n\n";
  });
templates['user-database'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div class=\"container-fluid\">\n\n  <div class=\"row-fluid\">\n\n    <div class=\"span6\">\n      <div class=\"well\" style=\"padding: 9.5px;\">\n        <div class=\"query-editor\"></div>\n        <hr/>\n        <button class=\"run-query btn btn-primary\">Run Query</button>\n      </div>\n    </div>\n\n\n    <div class=\"span6\">\n      <pre><code class=\"output json\">";
  if (stack1 = helpers.json) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.json; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "</code></pre>\n    </div>\n\n  </div>\n\n</div>\n\n";
  return buffer;
  });
})();
(function() {
  var template = Handlebars.template, templates = Handlebars.templates = Handlebars.templates || {};
templates['database-page'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [3,'>= 1.0.0-rc.4'];
helpers = helpers || Handlebars.helpers; data = data || {};
  


  return "<div id=\"database-view\">\n\n</div>\n";
  });
templates['edit-page'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [3,'>= 1.0.0-rc.4'];
helpers = helpers || Handlebars.helpers; data = data || {};
  


  return "<div id=\"save-notification\">\n  <p>\n    <a href=\"#\" class=\"save-changes\">Click here</a> for your changes to go live.\n  </p>\n</div>\n\n<div id=\"client-server-collection-view\">\n  <div class=\"left-sidebar-container\">\n    <div class=\"left-sidebar\">\n\n      <ul class=\"nav nav-tabs nav-stacked\">\n\n        <li class=\"dropdown\">\n        <a class=\"dropdown-toggle\" data-toggle=\"dropdown\" href=\"#\">\n          Create <b class=\"caret\"></b>\n        </a>\n        <ul class=\"dropdown-menu create-menu\">\n          <li class=\"html\"><a href=\"#\">HTML</a></li>\n          <li class=\"css\"><a href=\"#\">CSS</a></li>\n          <li class=\"js\"><a href=\"#\">JS</a></li>\n          <li class=\"divider\"></li>\n          <li class=\"dynamic\"><a href=\"#\">Dynamic Path</a></li>\n          <li class=\"template\"><a href=\"#\">Template</a></li>\n        </ul>\n        </li>\n\n        <li class=\"upload-files\"><a href=\"#\">Upload Files</a></li>\n\n      </ul>\n\n      <div class=\"well\" style=\"padding: 8px 0;\">\n        <ul class=\"file-list required nav nav-list\">\n          <li class=\"nav-header\">Required Files</li>\n        </ul>\n\n        <ul class=\"nav nav-list\">\n          <li class=\"divider\"></li>\n        </ul>\n\n        <ul class=\"file-list html nav nav-list\">\n          <li class=\"nav-header\">HTML</li>\n        </ul>\n\n        <ul class=\"file-list css nav nav-list\">\n          <li class=\"nav-header\">CSS</li>\n        </ul>\n\n        <ul class=\"file-list js nav nav-list\">\n          <li class=\"nav-header\">JS</li>\n        </ul>\n\n        <ul class=\"file-list img nav nav-list\">\n          <li class=\"nav-header\">Images</li>\n        </ul>\n\n        <ul class=\"nav nav-list\">\n          <li class=\"divider\"></li>\n        </ul>\n\n        <ul class=\"file-list dynamic nav nav-list\">\n          <li class=\"nav-header\">Dynamic Files</li>\n        </ul>\n\n      </div>\n\n    </div>\n  </div>\n\n  <div class=\"main-pane\">\n    <div id=\"file-view-container\"> </div>\n\n    <div id=\"route-view-container\"> </div>\n\n    <div class=\"file-drop well well-large\">\n      <div class=\"file-drop-inner\">\n        <h3>Drop files here</h3>\n      </div>\n    </div>\n  </div>\n\n</div>\n\n";
  });
templates['editable-file-list-item'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [3,'>= 1.0.0-rc.4'];
helpers = helpers || Handlebars.helpers; data = data || {};
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
templates['file-delete-confirmation'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [3,'>= 1.0.0-rc.4'];
helpers = helpers || Handlebars.helpers; data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div class=\"file-delete-confirmation modal hide\" data-cid=\"";
  if (stack1 = helpers.cid) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.cid; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "\">\n  <div class=\"modal-header\">\n    <button type=\"button\" class=\"close\" data-dismiss=\"modal\" aria-hidden=\"true\">&times;</button>\n    <h3>Are you sure that you want to delete ";
  if (stack1 = helpers.name) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.name; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "?</h3>\n  </div>\n  <div class=\"modal-body\">\n  </div>\n  <div class=\"modal-footer\">\n    <a href=\"#\" class=\"btn\" data-dismiss=\"modal\">Cancel</a>\n    <a href=\"#\" class=\"btn btn-danger deletion-confirmed\">Delete ";
  if (stack1 = helpers.name) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.name; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "</a>\n  </div>\n</div>\n\n";
  return buffer;
  });
templates['file-list-item'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [3,'>= 1.0.0-rc.4'];
helpers = helpers || Handlebars.helpers; data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n  <li data-cid=\"";
  if (stack1 = helpers.cid) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.cid; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "\"><a href=\"#\">";
  if (stack1 = helpers.name) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.name; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "</a></li>\n";
  return buffer;
  }

function program3(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n  <li class=\"dropdown\" data-cid=\"";
  if (stack1 = helpers.cid) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.cid; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "\">\n    <a class=\"dropdown-toggle\" data-toggle=\"dropdown\" href=\"#\">\n      ";
  if (stack1 = helpers.name) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.name; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + " <b class=\"caret pull-right\" style=\"display: none;\"></b>\n    </a>\n    <ul class=\"dropdown-menu\" style=\"display: none;\">\n      <li class=\"rename\"><a href=\"#\">Rename</a></li>\n      <li class=\"delete\"><a href=\"#\">Delete</a></li>\n    </ul>\n  </li>\n";
  return buffer;
  }

  stack1 = helpers['if'].call(depth0, depth0.isRequired, {hash:{},inverse:self.program(3, program3, data),fn:self.program(1, program1, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n\n";
  return buffer;
  });
templates['image'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [3,'>= 1.0.0-rc.4'];
helpers = helpers || Handlebars.helpers; data = data || {};
  


  return "<img src=\"\"></img>\n\n";
  });
templates['route-function-signature'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [3,'>= 1.0.0-rc.4'];
helpers = helpers || Handlebars.helpers; data = data || {};
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
  this.compilerInfo = [3,'>= 1.0.0-rc.4'];
helpers = helpers || Handlebars.helpers; data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  var stack1;
  if (stack1 = helpers.name) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.name; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  return escapeExpression(stack1);
  }

function program3(depth0,data) {
  
  
  return "(No name yet)";
  }

  buffer += "<li class=\"dropdown\" data-cid=\"";
  if (stack1 = helpers.cid) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.cid; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "\">\n  <a class=\"dropdown-toggle\" data-toggle=\"dropdown\" href=\"#\">\n    ";
  stack1 = helpers['if'].call(depth0, depth0.name, {hash:{},inverse:self.program(3, program3, data),fn:self.program(1, program1, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += " <b class=\"caret pull-right\" style=\"display: none;\"></b>\n  </a>\n  <ul class=\"dropdown-menu\" style=\"display: none;\">\n    <li class=\"delete\"><a href=\"#\">Delete</a></li>\n  </ul>\n</li>\n\n";
  return buffer;
  });
templates['route'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [3,'>= 1.0.0-rc.4'];
helpers = helpers || Handlebars.helpers; data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div class=\"route-path\">\n  URL at which the code below will be executed\n  <span class=\"help\">(Path components entered as \"&lt;someText&gt;\" will become variables,\n  accessible by your function below.)</span>\n  <br/>\n  <input type=\"text\" class=\"path input-xlarge\" value=\"";
  if (stack1 = helpers.path) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.path; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "\">\n</div>\n\n<div class=\"well function\" style=\"padding: 8px;\">\n  <div class=\"function-signature\"></div>\n\n  <div class=\"route-help\">\n    <p>\n      // Use `static_file(\"filename\")` to access static files.\n    </p>\n    <p>\n      // Use the Taffy `database` object to save state <br/>\n      // (see <a href=\"http://www.taffydb.com/\">TaffyDB</a> for how to use it)\n    </p>\n  </div>\n\n  <div class=\"code\"></div>\n  \n  <div class=\"function-close\">}</div>\n</div>\n\n";
  return buffer;
  });
templates['source-code'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [3,'>= 1.0.0-rc.4'];
helpers = helpers || Handlebars.helpers; data = data || {};
  


  return "<div class=\"file-contents\"></div>\n\n";
  });
templates['user-database'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [3,'>= 1.0.0-rc.4'];
helpers = helpers || Handlebars.helpers; data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div class=\"container-fluid\">\n\n  <div class=\"row-fluid\">\n\n    <div class=\"span6\">\n      <div class=\"well\" style=\"padding: 9.5px;\">\n        <div class=\"query-editor\"></div>\n        <hr/>\n        <button class=\"run-query btn btn-primary\">Run Query</button>\n      </div>\n    </div>\n\n\n    <div class=\"span6\">\n      <pre><code class=\"output json\">";
  if (stack1 = helpers.json) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.json; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "</code></pre>\n    </div>\n\n  </div>\n\n</div>\n\n";
  return buffer;
  });
})();
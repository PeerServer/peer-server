/* Set up bindings for real server. 

   Handle handshake between clientServer and clientBrowser
   */

/* Load in dependencies */
var config = require('getconfig'),
    uuid = require('node-uuid'),
    http = require('http'),
    fs = require('fs');
var app = require('express')();

/* Create the real server for the app */
var server = require('http').createServer(app);
var io = require('socket.io');

var port = process.env.PORT || config.server.port || 5000;
/* Start the server at the port. */
server.listen(port, function() {
  console.log('Server running at port ' + port);
});

/* Static file mappings */
app.param('filename');

app.get('/server/', function(req, res) {
  res.sendfile(__dirname + '/server/index.html');
});

app.get('/server/:filename(*)', function(req, res) {
  var filename = req.params.filename;
  res.sendfile(__dirname + '/server/' + filename);
});

app.get('/connect/:serverid(*)', function(req, res) {
  var serverid = req.params.serverid;
  res.sendfile(__dirname + '/client/index.html');
});

app.get('/client/:filename(*)', function(req, res) {
  var filename = req.params.filename;
  res.sendfile(__dirname + '/client/' + filename);
});

app.get('/shared/:filename(*)', function(req, res) {
  var filename = req.params.filename;
  res.sendfile(__dirname + '/shared/' + filename);
});

// /* Temporary mapping kept at the bottom just for testing test files 
//     outside of the server browser. */
// app.get('/test', function(req, res) {
//   var filename = req.params.filename;
//   res.sendfile(__dirname + '/test_files/wrapper.html');
// });

// /* Temporary mapping kept at the bottom just for testing. TODO remove. */
// app.get(':filename(*)', function(req, res) {
//   var filename = req.params.filename;
//   res.sendfile(__dirname + '/test_files/bootstrap-example/' + filename);
// });
app.get("/", function(req, res) {
  res.sendfile(__dirname + '/home/index.html');
})

/* Real server is notified when a browser attaches to it. 
   socket = a user connecting to our real server. May become either a 
   client server or client browser*/
io = io.listen(server);

io.configure(function () { 
  io.set("transports", ["xhr-polling"]); 
  io.set("polling duration", 10); 
});

io.sockets.on("connection", function(socket) {

  socket.emit("setID", uuid.v1());

  socket.on("newDataChannel", function (data) {
    console.log("NEW CHANNEL", data.channel);
    onNewNamespace(socket, data.channel, data.sender);
  });
});

function onNewNamespace(socket, channel, sender) {
  io.of('/' + channel).on("connection", function (socket) {
    console.log("CHANNEL", channel);

    if (io.isConnected) {
      io.isConnected = false;
      socket.emit("connect", true);
    }

    socket.on("message", function (data) {
      if (data.sender == sender)  {
        console.log("MESSAGE", data);
        socket.broadcast.emit("message", data.data);
      }
    });
  });
}

/* Set UID of process from config if applicable */
if (config.uid) {
  process.setuid(config.uid);
}

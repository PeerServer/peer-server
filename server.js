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

io.sockets.on('connection', function(socket) {
  
  /* Add the socket to the client server pool */
  socket.on('joinAsClientServer', function () {
    console.log("client server joined");
    // socket.join("clientServer");
    socket.emit("setSocketId", socket.id)
  });

  /* Add the socket to the client browser pool */
  socket.on('joinAsClientBrowser', function (data) {
    console.log("client browser joined");
    var roomName = "client_" + data.desiredServer;
    socket.join(roomName);
    io.sockets.socket(data.desiredServer).emit("joined", socket.id);
    // io.sockets.in("clientServer").emit('joined', socket.id);
    socket.emit("setSocketId", socket.id)
    socket.emit("joinedToServer");
  });
  
  /* Next part of handshake -- client-browser sends offer, trigger a receive offer
    on the client-server. */
  socket.on("sendOffer", function(sessionDescription, desiredServer) {
    io.sockets.socket(desiredServer).emit("receiveOffer", socket.id, sessionDescription);
  });

  /* Client-server acknowledges offer, trigger a receive answer on the client-browser. */
  socket.on("sendAnswer", function(clientID, sessionDescription) {
    io.sockets.socket(clientID).emit("receiveAnswer", sessionDescription);
  });

  /* Receive ICE candidates and send to the correct socket. 
  ICE = Interactive Communication Establishment (google for details) */
  socket.on('sendICECandidate', function(clientID, candidate) {
    if (clientID == "server") {
      // TODO MAY BE BROKEN :( socket.id may be incorrect, might have to pass in actual one (which might not exist right now)
      io.sockets.socket(socket.id).emit("receiveICECandidate", socket.id, candidate);
    } else {
      io.sockets.socket(clientID).emit("receiveICECandidate", candidate);
    }
  });
  
  /* Disconnect client server and client browser 
  TODO untested -- artifact from other code. */
  // socket.on('disconnect', function () {
  //   console.log("disconnect");
  //   var rooms = io.sockets.manager.roomClients[socket.id];
  //   for (var name in rooms) {
  //     console.log(name);
  //     if (name == "server") {
  //       console.log("server disconnected");
  //       io.sockets.in("clientBrowser").emit('serverDisconnected');
  //     } else if (name == "client") {
  //       console.log("client disconnected");
  //       io.sockets.in("clientServer").emit('clientDisconnected', socket.id);
  //     }
  //   }
  // });
  
});

/* Set UID of process from config if applicable */
if (config.uid) {
  process.setuid(config.uid);
}

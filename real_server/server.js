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

/* Start the server at the port. */
server.listen(config.server.port, function() {
  console.log('Server running at: http://localhost:' + config.server.port);
});

/* Static file mappings */
app.param('filename');

app.get('/server', function(req, res) {
  res.sendfile(__dirname + '/server/index.html');
});

app.get('/server/:filename', function(req, res) {
  var filename = req.params.filename;
  res.sendfile(__dirname + '/server/' + filename);
});

app.get('/client', function(req, res) {
  res.sendfile(__dirname + '/client/index.html');
});

app.get('/client/:filename', function(req, res) {
  var filename = req.params.filename;
  res.sendfile(__dirname + '/client/' + filename);
});

app.get('/shared/:filename', function(req, res) {
  var filename = req.params.filename;
  console.log(filename);
  res.sendfile(__dirname + '/shared/' + filename);
});


/* Real server is notified when a browser attaches to it. 
     socket = a user connecting to our real server. May become */
io = io.listen(server);
io.sockets.on('connection', function(socket) {
  
  /* Add the socket to the client server pool */
  socket.on('joinAsClientServer', function () {
    console.log("client server joined");
    socket.join("clientServer");
    socket.emit("setSocketId", socket.id)
  });

  /* Add the socket to the client browser pool */
  socket.on('joinAsClientBrowser', function () {
    console.log("client browser joined");
    socket.join("clientBrowser");
    io.sockets.in("clientServer").emit('joined', socket.id);
    socket.emit("setSocketId", socket.id)
    socket.emit("joinedToServer");
  });
  
  /* Next part of handshake -- client-browser sends offer, trigger a receive offer
    on the client-server. */
  socket.on("sendOffer", function(sessionDescription) {
    io.sockets.in("clientServer").emit("receiveOffer", socket.id, sessionDescription);
  });

  /* Client-server acknowledges offer, trigger a receive answer on the client-browser. */
  socket.on("sendAnswer", function(clientID, sessionDescription) {
    io.sockets.socket(clientID).emit("receiveAnswer", sessionDescription);
  });

  /* Receive ICE candidates and send to the correct socket. 
  ICE = Interactive Communication Establishment (google for details) */
  socket.on('sendICECandidate', function(clientID, candidate) {
    if (clientID == "server") {
      io.sockets.in("clientServer").emit("receiveICECandidate", socket.id, candidate);
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

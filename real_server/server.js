var config = require('getconfig'),
  uuid = require('node-uuid'),
  http = require('http'),
  fs = require('fs');
var app = require('express')();
var server = require('http').createServer(app);
var io = require('socket.io');

server.listen(config.server.port, function() {
  console.log('Server running at: http://localhost:' + config.server.port);
});

app.get('/server', function(req, res) {
  res.sendfile(__dirname + '/server/index.html');
});

app.get('/server/web_rtc.js', function(req, res) {
  res.sendfile(__dirname + '/server/web_rtc.js');
});

app.get('/client', function(req, res) {
  res.sendfile(__dirname + '/client/index.html');
});

app.get('/client/web_rtc.js', function(req, res) {
  res.sendfile(__dirname + '/client/web_rtc.js');
});

app.get('/adapter.js', function(req, res) {
  res.sendfile(__dirname + '/adapter.js');
});

io = io.listen(server);
io.sockets.on('connection', function(client) {
  
  client.on('joinAsServer', function () {
    console.log("server joined");
    client.join("server");
    client.emit("setClientID", client.id);
  });

  client.on('joinAsClient', function () {
    console.log("client joined");
    client.join("client");
    io.sockets.in("server").emit('joined', client.id);
    client.emit("setClientID", client.id);
    client.emit("joinedToServer", client.id);
  });
  
  client.on("sendOffer", function(sessionDescription) {
    io.sockets.in("server").emit("receiveOffer", client.id, sessionDescription);
  });

  client.on("sendAnswer", function(clientID, sessionDescription) {
    io.sockets.socket(clientID).emit("receiveAnswer", sessionDescription);
  });

  //Receive ICE candidates and send to the correct socket
  client.on('sendICECandidate', function(clientID, candidate) {
    if (clientID == "server") {
      io.sockets.in("server").emit("receiveICECandidate", client.id, candidate);
    } else {
      io.sockets.socket(clientID).emit("receiveICECandidate", candidate);
    }
  });
  
  client.on('disconnect', function () {
    console.log("disconnect");
    var rooms = io.sockets.manager.roomClients[client.id];
    for (var name in rooms) {
      console.log(name);
      if (name == "server") {
        console.log("server disconnected");
        io.sockets.in("client").emit('serverDisconnected');
      } else if (name == "client") {
        console.log("client disconnected");
        io.sockets.in("server").emit('clientDisconnected', client.id);
      }
    }
  });
  
});

if (config.uid) {
  process.setuid(config.uid);
}

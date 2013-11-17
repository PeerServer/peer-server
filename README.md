# PeerServer: A Server in the Browser with WebRTC
Sophia Westwood and Brie Bunge
(sophia@cs.stanford.edu, @sophiawestwood) (brie@cs.stanford.edu)

## About
PeerServer is a peer-to-peer client server using WebRTC, where your browser acts as a server for other browsers across WebRTC peer-to-peer data channels. You can create a client-server within your browser tab, upload content, and generate dynamic content using a mock-database, templating system, and sessions. Any client browser that connects to your client server will behave as if it is talking to a traditional server while in fact exclusively hitting your server.

This system allows you to quickly create a decentralized, short-lived web application where all the content lives within your browser. The traditional server only performs the initial handshake between the client-browsers and the client-server; your browser serves all other content peer-to-peer.

We built PeerServer in 8 weeks for our Stanford senior project in Spring 2013.

Check it out and create a server! Visit [peer-server.com](http://www.peer-server.com) or follow instructions to run locally.

## Running the project locally
After running git clone:
Run `./scripts/coffee.sh` to compile the Coffeescript files and `./scripts/handlebars.sh` to compile the Handlebars files. Then, run  `./scripts/server.sh` to start the server. You should now be able to access `http://localhost:8890/server` and `http://localhost:8890/client` successfully!


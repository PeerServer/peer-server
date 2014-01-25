## PeerServer: A Server in the Browser with WebRTC

Sophia Westwood and Brie Bunge

(sophia@cs.stanford.edu, @sophiawestwood) (brie@cs.stanford.edu)

### About
PeerServer is a peer-to-peer client server using WebRTC, where your browser acts as a server for other browsers across WebRTC peer-to-peer data channels. You can create a client-server within your browser tab, upload content, and generate dynamic content using a mock-database, templating system, and sessions. Any client browser that connects to your client server will behave as if it is talking to a traditional server while in fact exclusively hitting your server.

This system allows you to quickly create a decentralized, short-lived web application where all the content lives within your browser. The traditional server only performs the initial handshake between the client-browsers and the client-server; your browser serves all other content peer-to-peer.

We built PeerServer in 8 weeks for our Stanford senior project in Spring 2013.


### Getting Started

This tutorial will walk you through how to make the canonical "Hello, world." page using PeerServer.

#### Create a new server

1. Go to [www.peer-server.com](http://www.peer-server.com/)
2. Type your server name in the input field. _Note: If the server name is already taken, you will be prompted to choose another name._
3. Click the "Create PeerServer" button. You will be asked to select a template. For the purposes of this tutorial, you should choose "Empty Template." But, feel free to explore the others. :) ![create server](http://s30.postimg.org/x4befdyoh/Screen_Shot_2014_01_24_at_4_51_17_PM.png)
4. A new tab should open, revealing your new server! ![new server](http://s30.postimg.org/657jk8c7l/Screen_Shot_2014_01_24_at_4_51_28_PM.png)
5. Click "Open Browser" in the nav bar.
6. Marvel at your very own "Hello, world." page.

#### What just happened?

You might be wondering, "Well, okay. Why is this so awesome?" What just transpired is really cool! The first tab is your server, so its responsibility is to serve pages. But, how can a tab serve a webpage? WebRTC allows for between-browser communication. PeerServer uses the data channel capability of WebRTC. The data channel lets you send any sort of data between tabs. In this case, the server tab sends HTTP-like data (analogous to a HTTP server, such as Apache). The second tab is the browser, or client, of the server in the first tab. The PeerServer code on the browser/client tab overrides the standard HTTP requests, ensuring that everything is sent over the data channel.

[Read more on the inner workings of PeerServer](TODO)

#### A tour of the server

- Let's head back to the server tab.
- Click on "index.html" in the sidebar. This is the page contains the content you saw in the PeerServer browser's tab. ![index page](http://s30.postimg.org/4ow1239ap/Screen_Shot_2014_01_24_at_4_51_35_PM.png)
- Next, click on "default" under "Dynamic Files". When the PeerServer browser visits http://www.peer-server.com/connect/[your server name]/, this default dynamic file is loaded. ![default dynamic file](http://s20.postimg.org/h6tzkhuh9/Screen_Shot_2014_01_24_at_5_16_23_PM.png) ![default dynamic file - annotated](http://s20.postimg.org/6la48ho5p/Screen_Shot_2014_01_24_at_5_16_23_PM.png)

#### (Optional) Running the project locally

We just walked through how to create a server at peer-server.com. Here is how to run your own instance locally.

After running git clone:
From the `scripts` directory, run `coffee.sh` to compile the Coffeescript files and `handlebars.sh` to compile the Handlebars files.

Then, run  `server.sh` to start the server.

You should now be able to access `http://localhost:8890` successfully!


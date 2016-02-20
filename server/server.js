
var serverSocket = require('socket.io')(3000);

serverSocket.on('connection', function(client) {

	console.log("connection: " + client.id);

	client.broadcast.emit("addPlayer", 
    	{ xLocation: 100, yLocation: 100, zRotation: 1 });

    client.on("disconnect", function() {
    	console.log("disconnect: " + client.id);
    });

    client.on("update", function(data) {
    	client.broadcast.emit("update", data);
    });
});

var serverSocket = require('socket.io')(3000);

serverSocket.on('connection', function(client) {

	console.log("connection: " + client.id);

	client.on("addPlayer", function(data) {
    	serverSocket.emit("addPlayer", 
    		{ xLocation: 100, yLocation: 100, orientation: 1 });
    });

    client.on("disconnect", function() {
    	console.log("disconnect: " + client.id);
    });

    client.on("update", function(data) {
    	client.broadcast.emit("update", data);
    });
});
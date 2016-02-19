
var serverSocket = require('socket.io')(3000);

serverSocket.on('connection', function(client) {

	console.log("connection: " + client.id);

    client.on("disconnect", function() {
    	console.log("disconnect: " + client.id);
    });

    client.on("move player", function(data) {
    	console.log("move player: " + data);
    });
});
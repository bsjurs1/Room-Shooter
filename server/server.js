
var ServerSocket = require('socket.io')(3000);
var GameLoop = require('node-gameloop');
var Player = require('./Player');

var players = [];

ServerSocket.on('connection', function(client) {

	console.log("connection: " + client.id);

    var player = new Player(client.id);

    players.push(player);

    console.log("There are currently " + players.length + " player(s) active");

    client.player = player;

    client.emit("init", players);
    client.broadcast.emit("add", player);

    client.on("disconnect", function() {
    	console.log("disconnect: " + client.id);
        client.broadcast.emit("remove", client.id);
        players = players.filter(function(player) {
            if (player.id != client.player.id)
                return player;
        });
        console.log("There are currently " + players.length + " player(s) active");
    });

    client.on("move", function(data) {
        client.player.move(data);
    });
});

var gameLoopId = GameLoop.setGameLoop(function(delta) {

    players.forEach(function(player) {
        player.update();
    });

    ServerSocket.emit("update", players);

}, 1000 / 30);
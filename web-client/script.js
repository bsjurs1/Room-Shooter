document.addEventListener('DOMContentLoaded', initialize, false);

var stage = new PIXI.Container();
   var renderer = PIXI.autoDetectRenderer(400, 300, {backgroundColor : 0xE0E4CC});


function initialize() {
    document.body.appendChild(renderer.view);

    var players = [];

    var bunnyTexture = PIXI.Texture.fromImage("assets/bunny.png");

    socket = io.connect('http://localhost:3000');

    socket.on("connect", function() {
    	console.log("connected");    	
    });

    socket.on("disconnect", function() {
    	console.log("disconnected");
    });

    socket.on("init", function(remotePlayers) {

    	console.log("init: " + remotePlayers.length);

    	remotePlayers.forEach(function(remotePlayer) {
    		addPlayer(remotePlayer);
    	});

    	console.log("There are currently " + players.length + " player(s)");
    });

    socket.on("add", function(remotePlayer) {
    	console.log("add: " + remotePlayer.id);

    	addPlayer(remotePlayer);

    	console.log("There are currently " + players.length + " player(s)");
    });

    socket.on("remove", function(id) {
    	console.log("remove: " + id);
        players = players.filter(function(player) {
            if (player.id != id)
                return player;
        });
        console.log("There are currently " + players.length + " player(s)");
    });

    socket.on("update", function(remotePlayers) {
    	for (var i = 0; i < players.length; i++) {
    		var removePlayer = remotePlayers[i];
    		var localPlayer = players[i];
    		localPlayer.x = removePlayer.x;
    		localPlayer.y = removePlayer.y;
    	}
    });

    window.addEventListener('keydown', function() {
    	if (event.keyCode == 87) {
    		socket.emit("move", "W");
    	} else if (event.keyCode == 83) {
    		socket.emit("move", "S");
    	} else if (event.keyCode == 65) {
    		socket.emit("move", "A");
    	} else if (event.keyCode == 68) {
    		socket.emit("move", "D");
    	}
    }, true);

    window.addEventListener('keyup', function() {

    }, false);

    animate();

    function addPlayer(remotePlayer) {
    	var player = new PIXI.Sprite(bunnyTexture);
		player.id = remotePlayer.id;
		player.x = remotePlayer.x;
		player.y = remotePlayer.y;
	    	
	    players.push(player);
	    stage.addChild(player);
    }
}


function animate() {
    requestAnimationFrame(animate);
    renderer.render(stage);
}


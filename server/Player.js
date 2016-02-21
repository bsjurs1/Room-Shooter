
module.exports = Player;

function Player(id) {

	this.moveSpeed = 2;

	this.id = id;
	
	this.x = 100;
	this.y = 100;
}

Player.prototype = {
	update: function() {
		// TODO: update player position
	},
	move: function(key) {
		if (key == "W") {
			this.y += this.moveSpeed;
		} else if (key == "S") {
			this.y -= this.moveSpeed;
		} else if (key == "A") {
			this.x -= this.moveSpeed;
		} else if (key == "D") {
			this.x += this.moveSpeed;
		}
	}
}
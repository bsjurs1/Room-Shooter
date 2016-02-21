
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
	move: function(directions) {
		if (directions.up)
			this.y -= this.moveSpeed;
		if (directions.down)
			this.y += this.moveSpeed;
		if (directions.left)
			this.x -= this.moveSpeed;
		if (directions.right)
			this.x += this.moveSpeed
	}
}
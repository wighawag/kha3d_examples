package;

import kha.System;

class Main {

	public static function main() {
		System.init({width:640, height: 480}, init);
	}

	static function init() {
		var game = new Empty();
		System.notifyOnRender(game.render);
	}
}

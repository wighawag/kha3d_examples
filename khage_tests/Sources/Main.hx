package;

import kha.System;
import kha.Scheduler;

class Main {

	public static function main() {
		System.init({width:640, height: 480}, init);
	}

	static function init() {
		kha.Assets.loadEverything(loadingFinished);
	}

	static function loadingFinished(){
		var game = new Test();
		System.notifyOnRender(game.render);
        Scheduler.addTimeTask(game.update, 0, 1 / 60);
	}
}

package;

import kha.Game;
import kha.Framebuffer;
import kha.Color;

using Khage;

class Empty extends Game {

	public function new() {
		super("Empty");
	}

	override public function render(frame:Framebuffer) {

		frame.usingG4({
				g4.clear(Color.Black);
		});
		
  }
}

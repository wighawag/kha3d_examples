package;

import kha.Game;
import kha.Framebuffer;
import kha.Color;

import khage.g4.Buffer;

using Khage;

class Empty extends Game {

	var buffer : Buffer<{pos:Vec3}>;

	public function new() {
		super("Empty", false);
	}

	override public function init() {
		buffer = new Buffer<{pos:Vec3}>(3,3,StaticUsage);

		buffer.rewind();
		buffer.write_pos(-1.0, -1.0, 0.0); // Bottom-left
	  buffer.write_pos(1.0, -1.0, 0.0); // Bottom-right
	  buffer.write_pos(0.0,  1.0, 0.0);  // Top

		buffer.writeIndex(0);
		buffer.writeIndex(1);
		buffer.writeIndex(2);
  }

	override public function render(frame:Framebuffer) {
		frame.usingG4({
			g4.usingProgram("simple.vert","simple.frag",{
				g4.clear(Color.Black);
				program.draw(buffer);
			});

		});
  }
}

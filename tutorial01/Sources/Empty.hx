package;

import kha.Framebuffer;
import kha.Color;

using Khage;

import khage.g4.Buffer;

class Empty {

	var buffer : Buffer<{pos:Vec3}>; //required , TODO get rid of the requirement

	public function new() {
		buffer = new Buffer<{pos:Vec3}>(3,3,StaticUsage); //required
	}

	public function render(frame:Framebuffer) {
		frame.usingG4({
			g4.usingPipeline("simple.vert","simple.frag",{
				g4.clear(Color.Black);
			});

		});
    }
}

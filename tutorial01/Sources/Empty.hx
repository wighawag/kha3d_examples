package;

import kha.Framebuffer;
import kha.Color;

using Khage;

class Empty {

	public function new() {

    }

	public function render(frame:Framebuffer) {
		frame.usingG4({
			g4.usingPipeline("simple.vert","simple.frag",{
				g4.clear(Color.Black);
			});

		});
    }
}

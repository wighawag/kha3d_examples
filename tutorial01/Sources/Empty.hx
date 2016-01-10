package;

import kha.Framebuffer;
import kha.Color;

import khage.g4.Buffer;

using Khage;

class Empty {

	var buffer : Buffer<{pos:Vec3}>;

	public function new() {

		buffer = new Buffer<{pos:Vec3}>(3,3,StaticUsage);

		buffer.rewind();
		buffer.write_pos(-1.0, -1.0, 0.0); // Bottom-left
	  	buffer.write_pos(1.0, -1.0, 0.0); // Bottom-right
	  	buffer.write_pos(0.0,  1.0, 0.0);  // Top

		buffer.writeIndex(0);
		buffer.writeIndex(1);
		buffer.writeIndex(2);		
        
    }

	public function render(frame:Framebuffer) {
		frame.usingG4({
			g4.usingPipeline("simple.vert","simple.frag",{
				stencil:{
					mode: CompareMode.Always
				},
				depth:{
					write:false,
					mode:CompareMode.Always
				}
			},{
				g4.clear(Color.Green);
				pipeline.draw(buffer);
			});

		});
    }
}

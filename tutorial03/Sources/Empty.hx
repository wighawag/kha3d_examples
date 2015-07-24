package;

import kha.Game;
import kha.Framebuffer;
import kha.Color;

import kha.graphics4.Usage;

import kha.math.Matrix4;
import kha.math.Vector3;

import khage.g4.Buffer;
using Khage;

class Empty extends Game {

	var mvp:Matrix4;
	var buffer : Buffer<{pos:Vec3}>;

	public function new() {
		super("Empty");
	}

	override public function init() {

		// Projection matrix: 45° Field of View, 4:3 ratio, display range : 0.1 unit <-> 100 units
		var projection = Matrix4.perspectiveProjection(45.0, 4.0 / 3.0, 0.1, 100.0);
		// Or, for an ortho camera
		//var projection = Matrix4.orthogonalProjection(-10.0, 10.0, -10.0, 10.0, 0.0, 100.0); // In world coordinates

		// Camera matrix
		var view = Matrix4.lookAt(new Vector3(4, 3, 3), // Camera is at (4, 3, 3), in World Space
								  new Vector3(0, 0, 0), // and looks at the origin
								  new Vector3(0, 1, 0) // Head is up (set to (0, -1, 0) to look upside-down)
		);

		// Model matrix: an identity matrix (model will be at the origin)
		var model = Matrix4.identity();
		// Our ModelViewProjection: multiplication of our 3 matrices
		// Remember, matrix multiplication is the other way around
		mvp = Matrix4.identity();
		mvp = mvp.multmat(projection);
		mvp = mvp.multmat(view);
		mvp = mvp.multmat(model);

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
			g4.clear(Color.fromFloats(0.0, 0.0, 0.3));

			g4.usingProgram("simple.vert","simple.frag",{
				program.set_MVP(mvp);
				program.draw(buffer);
			});

		});

  }
}

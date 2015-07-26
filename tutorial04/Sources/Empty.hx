package ;

import kha.Game;
import kha.Framebuffer;
import kha.Color;

import kha.graphics4.Usage;
import kha.graphics4.CompareMode;

import kha.math.Matrix4;
import kha.math.Vector3;

import khage.g4.Buffer;
using Khage;

class Empty extends Game {

	// An array of vertices to form a cube
	static var vertices:Array<Float> = [
	    -1.0,-1.0,-1.0,
		-1.0,-1.0, 1.0,
		-1.0, 1.0, 1.0,
		 1.0, 1.0,-1.0,
		-1.0,-1.0,-1.0,
		-1.0, 1.0,-1.0,
		 1.0,-1.0, 1.0,
		-1.0,-1.0,-1.0,
		 1.0,-1.0,-1.0,
		 1.0, 1.0,-1.0,
		 1.0,-1.0,-1.0,
		-1.0,-1.0,-1.0,
		-1.0,-1.0,-1.0,
		-1.0, 1.0, 1.0,
		-1.0, 1.0,-1.0,
		 1.0,-1.0, 1.0,
		-1.0,-1.0, 1.0,
		-1.0,-1.0,-1.0,
		-1.0, 1.0, 1.0,
		-1.0,-1.0, 1.0,
		 1.0,-1.0, 1.0,
		 1.0, 1.0, 1.0,
		 1.0,-1.0,-1.0,
		 1.0, 1.0,-1.0,
		 1.0,-1.0,-1.0,
		 1.0, 1.0, 1.0,
		 1.0,-1.0, 1.0,
		 1.0, 1.0, 1.0,
		 1.0, 1.0,-1.0,
		-1.0, 1.0,-1.0,
		 1.0, 1.0, 1.0,
		-1.0, 1.0,-1.0,
		-1.0, 1.0, 1.0,
		 1.0, 1.0, 1.0,
		-1.0, 1.0, 1.0,
		 1.0,-1.0, 1.0
	];
	// Array of colors for each cube vertex
	static var colors:Array<Float> = [
	    0.583,  0.771,  0.014,
		0.609,  0.115,  0.436,
		0.327,  0.483,  0.844,
		0.822,  0.569,  0.201,
		0.435,  0.602,  0.223,
		0.310,  0.747,  0.185,
		0.597,  0.770,  0.761,
		0.559,  0.436,  0.730,
		0.359,  0.583,  0.152,
		0.483,  0.596,  0.789,
		0.559,  0.861,  0.639,
		0.195,  0.548,  0.859,
		0.014,  0.184,  0.576,
		0.771,  0.328,  0.970,
		0.406,  0.615,  0.116,
		0.676,  0.977,  0.133,
		0.971,  0.572,  0.833,
		0.140,  0.616,  0.489,
		0.997,  0.513,  0.064,
		0.945,  0.719,  0.592,
		0.543,  0.021,  0.978,
		0.279,  0.317,  0.505,
		0.167,  0.620,  0.077,
		0.347,  0.857,  0.137,
		0.055,  0.953,  0.042,
		0.714,  0.505,  0.345,
		0.783,  0.290,  0.734,
		0.722,  0.645,  0.174,
		0.302,  0.455,  0.848,
		0.225,  0.587,  0.040,
		0.517,  0.713,  0.338,
		0.053,  0.959,  0.120,
		0.393,  0.621,  0.362,
		0.673,  0.211,  0.457,
		0.820,  0.883,  0.371,
		0.982,  0.099,  0.879
	];

	var buffer:Buffer<{pos:Vec3,col:Vec3}>;
	var mvp:Matrix4;

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

		var numVertices : Int = Std.int(vertices.length/3);
		buffer = new Buffer<{pos:Vec3,col:Vec3}>(numVertices,numVertices,StaticUsage);

		buffer.rewind();
		for (i in 0...numVertices) {
			buffer.write_pos(vertices[i*3+0],vertices[i*3+1],vertices[i*3+2]);
			buffer.write_col(colors[i*3+0],colors[i*3+1],colors[i*3+2]);
		}

		for (i in 0...numVertices) {
			buffer.writeIndex(i);
		}

  }

	override public function render(frame:Framebuffer) {
		// A graphics object which lets us perform 3D operations
		frame.usingG4({
			// Set depth mode
			g4.setDepthMode(true, CompareMode.Less);
			// Clear screen
			g4.clear(Color.fromFloats(0.0, 0.0, 0.3), 1.0);

			g4.usingProgram("simple.vert","simple.frag",{
				program.set_MVP(mvp);
				program.draw(buffer);
			});

		});

  }
}

package ;

import kha.Assets;
import kha.Framebuffer;
import kha.Color;

import kha.Image;


import kha.graphics4.Usage;
import kha.graphics4.CompareMode;
import kha.math.FastMatrix4;
import kha.math.FastVector3;

import khage.g4.Buffer;
using Khage;

class Empty{

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
	// Array of texture coords for each cube vertex
	static var uvs:Array<Float> = [
	    0.000059, 0.000004,
		0.000103, 0.336048,
		0.335973, 0.335903,
		1.000023, 0.000013,
		0.667979, 0.335851,
		0.999958, 0.336064,
		0.667979, 0.335851,
		0.336024, 0.671877,
		0.667969, 0.671889,
		1.000023, 0.000013,
		0.668104, 0.000013,
		0.667979, 0.335851,
		0.000059, 0.000004,
		0.335973, 0.335903,
		0.336098, 0.000071,
		0.667979, 0.335851,
		0.335973, 0.335903,
		0.336024, 0.671877,
		1.000004, 0.671847,
		0.999958, 0.336064,
		0.667979, 0.335851,
		0.668104, 0.000013,
		0.335973, 0.335903,
		0.667979, 0.335851,
		0.335973, 0.335903,
		0.668104, 0.000013,
		0.336098, 0.000071,
		0.000103, 0.336048,
		0.000004, 0.671870,
		0.336024, 0.671877,
		0.000103, 0.336048,
		0.336024, 0.671877,
		0.335973, 0.335903,
		0.667969, 0.671889,
		1.000004, 0.671847,
		0.667979, 0.335851
	];

	var buffer:Buffer<{pos:Vec3,uv:Vec2}>;
	var mvp:FastMatrix4;
  var image:Image;

	public function new() {
		// Load all assets defined in khafile.js
		Assets.loadEverything(loadingFinished);
	}

	function loadingFinished() {

		// Texture
		image = Assets.images.uvtemplate;

		// Projection matrix: 45° Field of View, 4:3 ratio, display range : 0.1 unit <-> 100 units
		var projection = FastMatrix4.perspectiveProjection(45.0, 4.0 / 3.0, 0.1, 100.0);
		// Or, for an ortho camera
		//var projection = Matrix4.orthogonalProjection(-10.0, 10.0, -10.0, 10.0, 0.0, 100.0); // In world coordinates

		// Camera matrix
		var view = FastMatrix4.lookAt(new FastVector3(4, 3, 3), // Camera is at (4, 3, 3), in World Space
			new FastVector3(0, 0, 0), // and looks at the origin
			new FastVector3(0, 1, 0) // Head is up (set to (0, -1, 0) to look upside-down)
		);

		// Model matrix : an identity matrix (model will be at the origin)
		var model = FastMatrix4.identity();
		// Our ModelViewProjection : multiplication of our 3 matrices
		// Remember, matrix multiplication is the other way around
		mvp = FastMatrix4.identity();
		mvp = mvp.multmat(projection);
		mvp = mvp.multmat(view);
		mvp = mvp.multmat(model);


		var numVertices : Int = Std.int(vertices.length/3);
		buffer = new Buffer<{pos:Vec3,uv:Vec2}>(numVertices,numVertices,StaticUsage);

		buffer.rewind();
		for (i in 0...numVertices) {
			buffer.write_pos(vertices[i*3+0],vertices[i*3+1],vertices[i*3+2]);
			buffer.write_uv(uvs[i*2+0],uvs[i*2+1]);
		}

		for (i in 0...numVertices) {
			buffer.writeIndex(i);
		}
  }

	public function render(frame:Framebuffer) {
		if(mvp == null){
			return;
		}
		// A graphics object which lets us perform 3D operations
		frame.usingG4({
			// Clear screen
			g4.clear(Color.fromFloats(0.0, 0.0, 0.3), 1.0);

			g4.usingPipeline("simple.vert","simple.frag",{depth:{write:true, mode: CompareMode.Less}},{
				pipeline.set_MVP(mvp);
				pipeline.set_myTextureSampler(image);
				pipeline.draw(buffer);
			});

		});
  }
}

package ;

import kha.Assets;
import kha.Scheduler;
import kha.Framebuffer;
import kha.Color;

import kha.Image;
import kha.Key;
import kha.graphics4.Usage;
import kha.graphics4.CompareMode;
import kha.math.FastMatrix4;
import kha.math.FastVector3;

import khage.g4.Buffer;
using Khage;


class Empty {

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

	var model:FastMatrix4;
	var view:FastMatrix4;
	var projection:FastMatrix4;


  var image:Image;

  var lastTime = 0.0;

	var position:FastVector3 = new FastVector3(0, 0, 5); // Initial position: on +Z
	var horizontalAngle = 3.14; // Initial horizontal angle: toward -Z
	var verticalAngle = 0.0; // Initial vertical angle: none

	var moveForward = false;
  var moveBackward = false;
  var strafeLeft = false;
  var strafeRight = false;
	var isMouseDown = false;

	var mouseX = 0.0;
	var mouseY = 0.0;
	var mouseDeltaX = 0.0;
	var mouseDeltaY = 0.0;

	var speed = 3.0; // 3 units / second
	var mouseSpeed = 0.005;

	public function new() {
		// Load all assets defined in khafile.js
	Assets.loadEverything(loadingFinished);
    }

	function loadingFinished() {

		// Texture
		image = Assets.images.uvtemplate;

		// Projection matrix: 45° Field of View, 4:3 ratio, display range : 0.1 unit <-> 100 units
		projection = FastMatrix4.perspectiveProjection(45.0, 4.0 / 3.0, 0.1, 100.0);
		// Or, for an ortho camera
		//projection = Matrix4.orthogonalProjection(-10.0, 10.0, -10.0, 10.0, 0.0, 100.0); // In world coordinates

		// Camera matrix
		view = FastMatrix4.lookAt(new FastVector3(4, 3, 3), // Camera is at (4, 3, 3), in World Space
							  new FastVector3(0, 0, 0), // and looks at the origin
							  new FastVector3(0, 1, 0) // Head is up (set to (0, -1, 0) to look upside-down)
		);

		// Model matrix: an identity matrix (model will be at the origin)
		model = FastMatrix4.identity();
		// Our ModelViewProjection: multiplication of our 3 matrices
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

		// Add mouse and keyboard listeners
		kha.input.Mouse.get().notify(onMouseDown, onMouseUp, onMouseMove, null);
		kha.input.Keyboard.get().notify(onKeyDown, onKeyUp);

		// Used to calculate delta time
		lastTime = Scheduler.time();
  }

	public function render(frame:Framebuffer) {
        if(image == null){
            return; //not everything is loaded, skip update
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

    public function update() {
        if(image == null){
            return; //not everything is loaded, skip update
        }
    	// Compute time difference between current and last frame
		var deltaTime = Scheduler.time() - lastTime;
		lastTime = Scheduler.time();

		// Compute new orientation
		if (isMouseDown) {
			horizontalAngle += mouseSpeed * mouseDeltaX * -1;
			verticalAngle += mouseSpeed * mouseDeltaY * -1;
		}

		// Direction : Spherical coordinates to Cartesian coordinates conversion
		var direction = new FastVector3(
			Math.cos(verticalAngle) * Math.sin(horizontalAngle),
			Math.sin(verticalAngle),
			Math.cos(verticalAngle) * Math.cos(horizontalAngle)
		);

		// Right vector
		var right = new FastVector3(
			Math.sin(horizontalAngle - 3.14 / 2.0),
			0,
			Math.cos(horizontalAngle - 3.14 / 2.0)
		);

		// Up vector
		var up = right.cross(direction);

		// Movement
		if (moveForward) {
			var v = direction.mult(deltaTime * speed);
			position = position.add(v);
		}
		if (moveBackward) {
			var v = direction.mult(deltaTime * speed * -1);
			position = position.add(v);
		}
		if (strafeRight) {
			var v = right.mult(deltaTime * speed);
			position = position.add(v);
		}
		if (strafeLeft) {
			var v = right.mult(deltaTime * speed * -1);
			position = position.add(v);
		}

		// Look vector
		var look = position.add(direction);

		// Camera matrix
		view = FastMatrix4.lookAt(position, // Camera is here
							  look, // and looks here : at the same position, plus "direction"
							  up // Head is up (set to (0, -1, 0) to look upside-down)
		);

		// Update model-view-projection matrix
		mvp = FastMatrix4.identity();
		mvp = mvp.multmat(projection);
		mvp = mvp.multmat(view);
		mvp = mvp.multmat(model);

		mouseDeltaX = 0;
		mouseDeltaY = 0;
    }

    function onMouseDown(button:Int, x:Int, y:Int) {
    	isMouseDown = true;
    }

    function onMouseUp(button:Int, x:Int, y:Int) {
    	isMouseDown = false;
    }

    function onMouseMove(x:Int, y:Int, movementX : Int, movementY : Int) {
    	mouseDeltaX = x - mouseX;
    	mouseDeltaY = y - mouseY;

    	mouseX = x;
    	mouseY = y;
    }

    function onKeyDown(key:Key, char:String) {
        if (key == Key.UP) moveForward = true;
        else if (key == Key.DOWN) moveBackward = true;
        else if (key == Key.LEFT) strafeLeft = true;
        else if (key == Key.RIGHT) strafeRight = true;
    }

    function onKeyUp(key:Key, char:String) {
        if (key == Key.UP) moveForward = false;
        else if (key == Key.DOWN) moveBackward = false;
        else if (key == Key.LEFT) strafeLeft = false;
        else if (key == Key.RIGHT) strafeRight = false;
    }
}

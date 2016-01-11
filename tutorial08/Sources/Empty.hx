package ;

import kha.Assets;
import kha.Framebuffer;
import kha.Color;
import kha.Image;
import kha.Scheduler;
import kha.Key;

import kha.graphics4.Usage;
import kha.graphics4.CompareMode;
import kha.math.FastMatrix4;
import kha.math.FastVector3;

import khage.g4.Buffer;
using Khage;

class Empty {

	var buffer: Buffer<{pos:Vec3,uv:Vec2,nor:Vec3}>;
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
		image = Assets.images.uvmap;

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

		// Parse .obj file
		var obj = new ObjLoader(Assets.blobs.suzanne_obj.toString());
		var data = obj.data;
		var indices = obj.indices;

		var numVertices : Int = Std.int(data.length/8);
		buffer = new Buffer<{pos:Vec3,uv:Vec2,nor:Vec3}>(numVertices,indices.length,StaticUsage);

		buffer.rewind();
		for (i in 0...numVertices) {
			buffer.write_pos(data[i*8+0],data[i*8+1],data[i*8+2]);
			buffer.write_uv(data[i*8+3],data[i*8+4]);
			buffer.write_nor(data[i*8+5],data[i*8+6],data[i*8+7]);
		}

		for (index in indices) {
			buffer.writeIndex(index);
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

			g4.usingPipeline("simple.vert","simple.frag",{cull:{mode: CullMode.CounterClockwise}, depth:{write:true, mode: CompareMode.Less}},{
				pipeline.set_MVP(mvp);
				pipeline.set_M(model);
				pipeline.set_V(view);
				pipeline.set_lightPos(4,4,4);
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

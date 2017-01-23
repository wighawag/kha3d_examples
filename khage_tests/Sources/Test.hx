package;


#if use_khage
import kha.Framebuffer;
import kha.Color;

using Khage;

import khage.g4.Buffer;
#else


/////////////////////
import kha.Framebuffer;
import kha.Color;
import kha.Shaders;
import kha.graphics4.TextureUnit;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.FragmentShader;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexData;
import kha.graphics4.Usage;
import kha.graphics4.ConstantLocation;
import kha.graphics4.CompareMode;
#end

class Test {

	var renderTarget : kha.Image;
	
	#if use_khage
	var screenVertBuffer : Buffer<{pos:Vec3, uv : Vec2}>;
	#else
	//////////////////////////////////////////////////////
	var vertexBuffer : VertexBuffer;
	var indexBuffer : IndexBuffer;
	var pipeline : PipelineState;
	var textureID : TextureUnit;
	#end

	public function new() {
		renderTarget = kha.Image.createRenderTarget(256,256);
		#if use_khage
		screenVertBuffer = new Buffer<{pos:Vec3, uv : Vec2}>(4,6,StaticUsage);
		screenVertBuffer.rewind();
		screenVertBuffer.write_pos(-1,-1,-1);
		screenVertBuffer.write_uv(0,0);
		screenVertBuffer.write_pos(1,-1,-1);
		screenVertBuffer.write_uv(1,0);
		screenVertBuffer.write_pos(1,1,-1);
		screenVertBuffer.write_uv(1,1);
		screenVertBuffer.write_pos(-1,1,-1);
		screenVertBuffer.write_uv(0,1);

		screenVertBuffer.writeIndex(0);
		screenVertBuffer.writeIndex(1);
		screenVertBuffer.writeIndex(2);
		screenVertBuffer.writeIndex(2);
		screenVertBuffer.writeIndex(3);
		screenVertBuffer.writeIndex(0);

		#else
		///////////////////////////////////////////////////
		var structure = new VertexStructure();
		structure.add('pos', VertexData.Float3);
		structure.add('uv', VertexData.Float2);
		vertexBuffer = new VertexBuffer(4*5, structure, Usage.StaticUsage);
		var buffer = vertexBuffer.lock();
		
		buffer.set(0 * 5 + 0, -1);
		buffer.set(0 * 5 + 1, -1);
		buffer.set(0 * 5 + 2, -1);
		buffer.set(0 * 5 + 3, 0);
		buffer.set(0 * 5 + 4, 0);

		buffer.set(1 * 5 + 0, 1);
		buffer.set(1 * 5 + 1, -1);
		buffer.set(1 * 5 + 2, -1);
		buffer.set(1 * 5 + 3, 1);
		buffer.set(1 * 5 + 4, 0);

		buffer.set(2 * 5 + 0, 1);
		buffer.set(2 * 5 + 1, 1);
		buffer.set(2 * 5 + 2, -1);
		buffer.set(2 * 5 + 3, 1);
		buffer.set(2 * 5 + 4, 1);

		buffer.set(3 * 5 + 0, -1);
		buffer.set(3 * 5 + 1, 1);
		buffer.set(3 * 5 + 2, -1);
		buffer.set(3 * 5 + 3, 0);
		buffer.set(3 * 5 + 4, 1);
		vertexBuffer.unlock();
		
		indexBuffer = new IndexBuffer(6, Usage.StaticUsage);
		var ibuffer = indexBuffer.lock();		
		ibuffer[0] = 0;
		ibuffer[1] = 1;
		ibuffer[2] = 2;
		ibuffer[3] = 2;
		ibuffer[4] = 3;
		ibuffer[5] = 0;
		indexBuffer.unlock();
		
		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.vertexShader = Shaders.overlay_vert;
		pipeline.fragmentShader = Shaders.overlay_frag;
		// pipeline.depthWrite = true;
		// pipeline.depthMode = CompareMode.Less;
		pipeline.compile();

		// textureID = pipeline.getTextureUnit("u_texture");
		#end
	}

	public function render(framebuffer:Framebuffer) {

		// var g = framebuffer.g2;
		// g.begin(true);
		// g.color = Color.Red;
		// g.fillRect(20, 20, 50, 50);
		// g.end();
		// return;

		var g = renderTarget.g2;
		g.begin(true);
		g.color = Color.Red;
		g.fillRect(20, 20, 50, 50);
		g.end();

		#if use_khage
		framebuffer.usingG4({
			g4.clear();
			g4.usingPipeline("overlay.vert","overlay.frag",{},{
				pipeline.set_u_texture(renderTarget);
				pipeline.draw(screenVertBuffer);
			});
		});
		#else
		///////////////////////////////////////////////////
		var g4 = framebuffer.g4;
		g4.begin();
		g4.clear(Color.Black, Math.POSITIVE_INFINITY);

		g4.setPipeline(pipeline);
		textureID = pipeline.getTextureUnit("u_texture");
		g4.setTexture(textureID, renderTarget);
		// g4.setTexture(textureID, kha.Assets.images.pattern);
		g4.setIndexBuffer(indexBuffer);
		g4.setVertexBuffer(vertexBuffer);
		g4.drawIndexedVertices();

		g4.end();
		#end
    }

    public function update() {

    }
}

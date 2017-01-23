attribute vec3 pos;
attribute vec2 uv;

varying vec2 _uv;

void main() {
	gl_Position = vec4(pos,1.0);
	_uv = uv;
}

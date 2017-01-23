precision mediump float;

varying vec2 _uv;

uniform sampler2D u_texture;

void main() {
	gl_FragColor = texture2D(u_texture, _uv);
}

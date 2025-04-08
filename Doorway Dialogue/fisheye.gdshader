shader_type spatial;
render_mode unshaded;
uniform sampler2D VIEWPORT_TEXTURE: source_color;

void fragment() {
	ALBEDO = texture(VIEWPORT_TEXTURE, SCREEN_UV).rgb;
	}
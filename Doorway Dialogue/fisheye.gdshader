// Converted from https://www.shadertoy.com/view/td2GzW
shader_type spatial;
uniform sampler2D VIEWPORT_TEXTURE;

void fragment() {
	ALBEDO = texture(VIEWPORT_TEXTURE, SCREEN_UV).rgb * 1.0;
	EMISSION = texture(VIEWPORT_TEXTURE, SCREEN_UV).rgb * 1.0;
	}
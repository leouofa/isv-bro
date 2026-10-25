shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float scanline_count : hint_range(100.0, 800.0) = 360.0;
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.25;
uniform float curvature : hint_range(0.0, 0.1) = 0.02;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.35;
uniform float chromatic_aberration : hint_range(0.0, 0.01) = 0.002;

vec2 curve_uv(vec2 uv) {
	uv = uv * 2.0 - 1.0;
	vec2 offset = abs(uv.yx) / vec2(6.0, 4.0);
	uv = uv + uv * offset * offset * curvature * 10.0;
	return uv * 0.5 + 0.5;
}

void fragment() {
	vec2 uv = curve_uv(SCREEN_UV);

	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		// Chromatic Aberration
		float r = texture(screen_texture, uv + vec2(chromatic_aberration, 0.0)).r;
		float g = texture(screen_texture, uv).g;
		float b = texture(screen_texture, uv - vec2(chromatic_aberration, 0.0)).b;
		vec3 color = vec3(r, g, b);

		// Scanlines
		float scanline = sin(uv.y * scanline_count * 3.14159 * 2.0) * 0.5 + 0.5;
		color *= 1.0 - (scanline * scanline_intensity);

		// Vignette
		vec2 vig_uv = uv * (1.0 - uv.yx);
		float vig = vig_uv.x * vig_uv.y * 15.0;
		vig = clamp(pow(vig, vignette_intensity), 0.0, 1.0);
		color *= vig;

		COLOR = vec4(color, 1.0);
	}
}

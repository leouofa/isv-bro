shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 grid_color : source_color = vec4(0.0, 0.94, 1.0, 1.0);
uniform vec4 bg_color : source_color = vec4(0.04, 0.02, 0.08, 1.0);
uniform float grid_spacing : hint_range(0.1, 10.0) = 1.5;
uniform float line_thickness : hint_range(0.01, 0.5) = 0.04;
uniform float scroll_speed : hint_range(0.0, 30.0) = 8.0;
uniform float fog_start : hint_range(0.0, 100.0) = 5.0;
uniform float fog_end : hint_range(10.0, 200.0) = 45.0;
uniform float glow_boost : hint_range(1.0, 5.0) = 2.2;

varying vec3 v_world_pos;

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 uv_pos = v_world_pos.xz;
	uv_pos.y += TIME * scroll_speed;

	vec2 grid = abs(fract(uv_pos / grid_spacing - 0.5) - 0.5) / (fwidth(uv_pos / grid_spacing) + 0.001);
	float line = min(grid.x, grid.y);
	float line_intensity = 1.0 - min(line * (1.0 - line_thickness), 1.0);

	float dist = length(v_world_pos.xz);
	float fog = clamp((dist - fog_start) / (fog_end - fog_start), 0.0, 1.0);

	vec3 final_color = mix(grid_color.rgb * glow_boost, bg_color.rgb, fog);
	ALBEDO = mix(bg_color.rgb, final_color, line_intensity);
}

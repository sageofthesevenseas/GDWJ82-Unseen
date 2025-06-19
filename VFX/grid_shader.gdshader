shader_type canvas_item;
render_mode unshaded;

uniform float grid_size = 1.0;
uniform vec2 grid_center = vec2(0.0);
uniform float width_outer = 0.15;
uniform float width_inner = 0.1;
uniform float bleed_power = 1.0;
uniform vec4 color : source_color = vec4(1.0);

void fragment() {
	vec2 a = fract((UV * 2.0 - 1.0 - grid_center) * grid_size / 2.0);
	vec2 b = max(0.5 - a, 0.0) + max(a - 0.5, 0.0);
	float c = max(b.x, b.y);
	float d = max(min((c * 2.0 - (1.0 - width_outer)) / (width_outer - width_inner), 1.0), 0.0);
	d = pow(d, bleed_power);
	COLOR = vec4(vec3(color.rgb), d * color.a);
}
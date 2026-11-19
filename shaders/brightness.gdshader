// Brightness setting: a gamma curve over the picture (world, tape texture, MIX), under the UI.
// gamma above 1 lifts the dark tones, below 1 deepens them; black and white stay where they are,
// so the calibration marks (proto_first_run.gd) move in and out of sight.
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float gamma = 1.0;

void fragment() {
	vec4 c = texture(screen_texture, SCREEN_UV);
	COLOR = vec4(pow(max(c.rgb, vec3(0.0)), vec3(1.0 / gamma)), 1.0);
}

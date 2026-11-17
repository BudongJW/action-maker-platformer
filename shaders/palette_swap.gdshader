// Palette swap for the "other world" (see assets/original/art/README.md).
//
// Replaces every pixel whose colour matches an entry of base_lut with the
// colour at the same position in swap_lut. Both lookup strips are 1 pixel
// high with one pixel per palette key:
//   base_lut = assets/original/art/palette/lut_night_school.png
//   swap_lut = assets/original/art/palette/lut_otherworld.png
// Import both with filtering off. Put the material on a CanvasGroup or a
// TileMapLayer that holds the world, and leave the player outside it to keep
// the player's own colours. Animate `amount` for a fade between worlds.
//
// Not yet tested in ACTION GAME MAKER G (no project exists yet).
shader_type canvas_item;

uniform sampler2D base_lut : filter_nearest;
uniform sampler2D swap_lut : filter_nearest;
uniform int palette_size = 20;
uniform float amount : hint_range(0.0, 1.0) = 1.0;
uniform float tolerance = 0.01;

void fragment() {
	vec4 src = texture(TEXTURE, UV);
	vec3 swapped = src.rgb;
	for (int i = 0; i < palette_size; i++) {
		vec2 at = vec2((float(i) + 0.5) / float(palette_size), 0.5);
		if (distance(src.rgb, texture(base_lut, at).rgb) < tolerance) {
			swapped = texture(swap_lut, at).rgb;
			break;
		}
	}
	COLOR = vec4(mix(src.rgb, swapped, amount), src.a);
}

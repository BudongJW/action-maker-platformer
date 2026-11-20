// Palette swap for the "other world" (see assets/original/art/README.md).
//
// Replaces every pixel whose colour matches an entry of base_lut with the
// colour at the same position in swap_lut. Both lookup strips are 1 pixel
// high with one pixel per palette key:
//   base_lut = assets/original/art/palette/lut_night_school.png
//   swap_lut = assets/original/art/palette/lut_otherworld.png
// Import both with filtering off. Put the material on each node drawn with the
// base palette (Sprite2D, AnimatedSprite2D, TextureRect, TileMapLayer; children
// can set use_parent_material), and leave the player off it to keep the
// player's own colours. Animate `amount` for a fade between worlds.
//
// It reads TEXTURE, so it does not work as a CanvasGroup material: a
// CanvasGroup's material receives the group's back buffer and has to sample it
// through a hint_screen_texture uniform at SCREEN_UV instead.
//
// Tested in plain Godot 4.7 through the prototype (scripts/proto/proto_art.gd,
// which builds the lookup strips from the .pal files). Not yet tested in
// ACTION GAME MAKER G.
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

// MIX: the LINEAR and HI-FI pictures of the same moment laid over each other.
//
// The screen holds the LINEAR picture; `hifi_layer` is a second view of the same world that
// shows what HI-FI shows (a SubViewport sharing the World2D, with canvas cull masks keeping each
// track's own nodes in its own view). The two alternate in a checkerboard of art pixels, and the
// HI-FI picture is pushed `shift` art pixels to the right, so whatever differs between the
// tracks shows twice (assets/original/mibangsong/README.md, cut 2-04).
//
// Both views draw the art with the LINEAR palette (one shared palette-swap material), so the
// HI-FI half is recoloured here: a colour found in `from_lut` (base keys -> LINEAR colours) is
// replaced by the colour at the same position in `to_lut` (base keys -> HI-FI colours).
// Colours found in neither (blended edges, graybox shapes) stay as they are.
//
// `grid_origin` is where the world origin is on screen and `art_pixel` the screen pixels per
// world pixel (the canvas transform's origin and zoom), so the checkerboard stays on the world's
// pixels while the camera moves. All positions are in the base viewport size (`view_size`).
//
// Tested in plain Godot 4.7 through the prototype (scripts/proto/proto_screen.gd). Not yet
// tested in ACTION GAME MAKER G.
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform sampler2D hifi_layer : filter_nearest;
uniform sampler2D from_lut : filter_nearest;
uniform sampler2D to_lut : filter_nearest;
uniform int palette_size = 0;
uniform float tolerance = 0.02;
uniform vec2 view_size = vec2(1280.0, 720.0);
uniform vec2 grid_origin = vec2(0.0);
uniform float art_pixel = 4.0;
uniform float shift = 3.0;

vec3 recolour(vec3 c) {
	for (int i = 0; i < palette_size; i++) {
		vec2 at = vec2((float(i) + 0.5) / float(palette_size), 0.5);
		if (distance(c, texture(from_lut, at).rgb) < tolerance) {
			return texture(to_lut, at).rgb;
		}
	}
	return c;
}

void fragment() {
	vec2 cell = floor((UV * view_size - grid_origin) / art_pixel);
	if (mod(cell.x + cell.y, 2.0) < 0.5) {
		COLOR = vec4(texture(screen_texture, SCREEN_UV).rgb, 1.0);
	} else {
		vec2 uv = UV - vec2(shift * art_pixel / view_size.x, 0.0);
		COLOR = vec4(recolour(texture(hifi_layer, uv).rgb), 1.0);
	}
}

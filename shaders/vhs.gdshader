// VHS texture for the tape picture: scanlines, colour that smears and trails to the right while
// brightness stays sharp (VHS keeps far less colour detail than brightness), grain, and a
// tracking band that rolls down the picture with its rows pushed sideways.
//
// Put it on a full-screen ColorRect in a CanvasLayer between the world and the UI, so the
// picture gets the texture and the dialogue window does not. It reads the screen, so a second
// screen-reading effect in the same layer needs a BackBufferCopy between the two.
//
// `lines` is the number of art rows on screen (180 for 320x180 art); scanlines and grain follow
// those rows. `clock` is set from a script (seconds) so recordings come out the same every time.
// `moving` = 0 freezes the grain and takes the band away; for reduced flashing the script also
// sets `scanline` to 0.
//
// Tested in plain Godot 4.7 through the prototype (scripts/proto/proto_screen.gd). Not yet
// tested in ACTION GAME MAKER G.
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform vec2 view_size = vec2(1280.0, 720.0);
uniform float lines = 180.0;
// How much darker the lower part of each art row gets. Keep it at 0.08 or below: scanline
// contrast above 10% over a fifth of the screen fails platform photosensitivity checks.
uniform float scanline : hint_range(0.0, 1.0) = 0.08;
// How far colour trails behind brightness, and how wide it smears, in art pixels.
uniform float chroma = 0.5;
uniform float chroma_blur = 1.0;
uniform float noise : hint_range(0.0, 0.5) = 0.04;
uniform float band : hint_range(0.0, 1.0) = 0.6;
// Seconds for the band to pass from top to bottom.
uniform float band_period = 9.0;
uniform float moving : hint_range(0.0, 1.0) = 1.0;
uniform float clock = 0.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

// NTSC YIQ: Y is brightness, I and Q the colour.
vec3 to_yiq(vec3 c) {
	return vec3(dot(c, vec3(0.299, 0.587, 0.114)), dot(c, vec3(0.596, -0.274, -0.322)),
		dot(c, vec3(0.211, -0.523, 0.312)));
}

vec3 from_yiq(vec3 y) {
	return vec3(y.x + 0.956 * y.y + 0.621 * y.z, y.x - 0.272 * y.y - 0.647 * y.z,
		y.x - 1.106 * y.y + 1.703 * y.z);
}

void fragment() {
	float row_px = view_size.y / lines;
	vec2 px = UV * view_size;
	float row = floor(px.y / row_px);
	float t = clock * moving;
	// The band starts above the picture and leaves below it; frozen, it stays out of sight.
	float band_row = fract(t / band_period) * (lines + 24.0) - 12.0;
	float in_band = band * moving * (1.0 - smoothstep(0.0, 6.0, abs(row - band_row)));
	float push = in_band * (hash(vec2(row, floor(t * 12.0))) - 0.5) * 2.0 * row_px / view_size.x;
	vec2 uv = SCREEN_UV + vec2(push, 0.0);
	float art_u = row_px / view_size.x;
	float luma = to_yiq(texture(screen_texture, uv).rgb).x;
	vec2 iq = vec2(0.0);
	for (int k = -1; k <= 1; k++) {
		float back = (chroma + float(k) * 0.5 * chroma_blur) * art_u;
		iq += to_yiq(texture(screen_texture, uv - vec2(back, 0.0)).rgb).yz;
	}
	vec3 c = from_yiq(vec3(luma, iq / 3.0));
	// The lower part of each art row is darker.
	c *= 1.0 - scanline * smoothstep(0.55, 1.0, fract(px.y / row_px));
	float grain = hash(floor(px / row_px) + vec2(floor(t * 24.0) * 7.13, 0.0)) - 0.5;
	c += grain * (noise + in_band * 0.08);
	COLOR = vec4(clamp(c, 0.0, 1.0), 1.0);
}

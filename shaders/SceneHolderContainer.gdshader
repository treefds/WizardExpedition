shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

uniform vec2 cam_offset = vec2(0.0, 0.0);
uniform vec2 abberation_offset = vec2(0.0, 0.0);
uniform float zoom_scale = 1.0;

void vertex() {
	VERTEX += cam_offset;
}

///*
void fragment() {
	
	vec2 uv = SCREEN_UV;
	vec2 zoomed_uv = ((uv - vec2(0.5, 0.5)) * zoom_scale + vec2(0.5, 0.5));
	
	COLOR.r = texture(TEXTURE, zoomed_uv - abberation_offset).r;
	COLOR.g = texture(TEXTURE, zoomed_uv).g;
	COLOR.b = texture(TEXTURE, zoomed_uv + abberation_offset).b;
	COLOR.a = texture(TEXTURE, zoomed_uv).a;
	
	
}
// */
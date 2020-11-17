shader_type canvas_item;

uniform sampler2D mask_texture;
uniform bool fliped = false;
uniform float opac = 1.0;

void fragment() {
	vec2 uv;
	if (fliped == true) {
		uv = vec2(1.0-UV.x,UV.y)
	} else {
		uv = UV
	}
    vec4 colour = texture(TEXTURE, UV);
    colour.a *= texture(mask_texture, uv).a;
	colour.a *= opac;

    COLOR = colour;
}
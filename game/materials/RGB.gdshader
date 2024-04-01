shader_type canvas_item;

// recreation of psych engine's rgb coloring shader
// this is my first attempt at making a shader in godot lol
// - Zyflx

// default rgb colors
// you can edit these if you want
// not sure for what reason but whatever
uniform vec4 def_r : source_color = vec4(1., 0., 0., 1.);
uniform vec4 def_g : source_color = vec4(0., 1., 0., 1.);
uniform vec4 def_b : source_color = vec4(0., 0., 1., 1.);

// your custom rgb colors
// this is what you want to edit
uniform vec4 r : source_color;
uniform vec4 g : source_color;
uniform vec4 b : source_color;

uniform bool enabled;

bool is_colored(vec4 col) {
	if (col.r <= 0. && col.g <= 0. && col.b <= 0.) {
		return false;
	}
	return true;
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (enabled) {
		// use the default rgb colors if the custom ones dont have a color assigned to them
		if (!is_colored(r) && !is_colored(g) && !is_colored(b)) {
			COLOR.rgb = min(COLOR.r * def_r.rgb + COLOR.g * def_g.rgb + COLOR.b * def_b.rgb, vec3(1.));
		} else {
			COLOR.rgb = min(COLOR.r * r.rgb + COLOR.g * g.rgb + COLOR.b * b.rgb, vec3(1.));
		}
	}
}
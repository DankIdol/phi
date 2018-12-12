shader_type canvas_item;
render_mode unshaded;

void fragment(){
	COLOR = vec4(COLOR.rgb * 0.8, 0.2);
}
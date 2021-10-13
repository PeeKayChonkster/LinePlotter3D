shader_type canvas_item;

uniform sampler2D points;
uniform vec4 lineColor: hint_color;
uniform float lineWidth;
uniform float pixelSize;

float IsUVOnLine(vec2 uv)
{
	float result = 0.0;
	int size = textureSize(points, 0).y;
	for(int i = 0; i < size; i++)
	{
		vec4 point = texelFetch(points, ivec2(0, i), 0);
		float alpha = clamp(distance(point.xy, uv)/distance(point.xy, point.zw), 0.0, 1.0);
		vec2 p3 = mix(point.xy, point.zw, alpha);
		// 1 = true, 0 = false
		result += 1.0 - floor(1.0 + distance(p3, uv) - pixelSize * lineWidth);
	}
	return ceil(mix(0.0, 1.0, result / float(size)));
}

void fragment()
{
	// 0 or 1
	float result = IsUVOnLine(SCREEN_UV);
	vec4 screenColor = COLOR;
	COLOR = vec4(screenColor.r * (1.0 - result) + lineColor.r * result, screenColor.g * (1.0 - result) + lineColor.g * result, 
				screenColor.b * (1.0 - result) + lineColor.b * result, screenColor.a * (1.0 - result) + lineColor.a * result);
	//COLOR = vec4(1.0, 0.0, 0.0, 1.0);
}


#define MAX_THICKNESS 8.0

varying vec2	v_vTexcoord;
varying vec4	v_vColour;

uniform vec4	u_line_color;
uniform vec2	u_pixel_size;
uniform vec3	u_thk_rn_tol;	// Thickness, roundness, tolerance
uniform vec4	u_uv;


float point_in_elipse(vec2 center, vec2 point, vec2 axis) {
	// Turn on again if scales are glitchy, but it mostly unlikely
	//vec2 semi_axis = vec2(max(axis.x, axis.y), min(axis.x, axis.y));
	
    float dist = (pow((point.x - center.x), 2.0) / pow(axis.x, 2.0))
			   + (pow((point.y - center.y), 2.0) / pow(axis.y, 2.0));
    return dist;
}


void main() {
	
	vec4 frag_col		= texture2D(gm_BaseTexture, v_vTexcoord);
	float thickness		= min(abs(u_thk_rn_tol.x), MAX_THICKNESS);
	float tolerance		= clamp(u_thk_rn_tol.z, 0.0, 0.999999);
	float outline		= 0.0;
	bool in_line		= u_thk_rn_tol.x < 0.0;
	bool stop			= false;
	
	// Invert the condition for inline cases
	if (frag_col.a <= tolerance ^^ in_line) {
		for (float xx = -MAX_THICKNESS; xx <= MAX_THICKNESS; xx++) {
			if (xx < -thickness) {continue;}
			if (xx > thickness) {break;}
			
			for (float yy = -MAX_THICKNESS; yy <= MAX_THICKNESS; yy++) {					
				if (yy < -thickness) {continue;}
				if (yy > thickness) {break;}
				
				vec2 loop_pos = vec2(xx, yy) * u_pixel_size;
				vec2 chk_pos = v_vTexcoord + loop_pos;
				
				// Sample all surrouding pixels - a two pass system would be better for thicker outlines
				vec4 chk_col = texture2D(gm_BaseTexture, chk_pos);	
				
				// Same inverted condition stuff
				if (chk_col.a > tolerance ^^ in_line) {
					
					// Check if the UV still on the sprite area
					bool out_bound = (chk_pos.x < u_uv.r || chk_pos.y < u_uv.g || chk_pos.x > u_uv.b || chk_pos.y > u_uv.a);
					vec2 axis = u_pixel_size.xy * thickness;
					
					// Elipse because texture page can be rectangular - maybe there is a better way but this does the job
					float dist = point_in_elipse(v_vTexcoord, chk_pos, axis);
					if (dist <= 2.0-u_thk_rn_tol.y && !out_bound) {
						outline = 1.0;
						stop = true;
						break;
					}
				}
			}
			if (stop) {
				break;
			}
		}
	}
	
	// Defines the final fragment color as the sampled or as the outline
	gl_FragColor = mix(v_vColour * frag_col, u_line_color, outline);
}
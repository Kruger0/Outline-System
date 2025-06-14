#define MAX_THICKNESS 8.0

varying vec2    v_vTexcoord;
varying vec4    v_vColour;

uniform vec4    u_line_color;
uniform vec2    u_pixel_size;
uniform vec3    u_thk_rn_tol;    // Thickness, roundness, tolerance
uniform vec4    u_uv;

void main() {
    
    vec4 frag_col   = texture2D(gm_BaseTexture, v_vTexcoord);
    float thickness = min(abs(u_thk_rn_tol.x), MAX_THICKNESS);
    float roundness = clamp(u_thk_rn_tol.y, 0.0, 1.0);
    float tolerance = clamp(u_thk_rn_tol.z, 0.0, 1.0);
    float outline   = 0.0;
    bool in_line    = u_thk_rn_tol.x < 0.0;
    bool stop       = false;
    
    // Invert the condition for inline cases
    if (frag_col.a <= tolerance ^^ in_line) {
        for (float xx = -MAX_THICKNESS; xx <= MAX_THICKNESS; xx++) {
            if (xx < -thickness) continue;
            if (xx > thickness) break;
            
            for (float yy = -MAX_THICKNESS; yy <= MAX_THICKNESS; yy++) {                    
                if (yy < -thickness) continue;
                if (yy > thickness) break;
                
                vec2 loop_pos = vec2(xx, yy) * u_pixel_size;
                vec2 chk_pos = v_vTexcoord + loop_pos;
                
                // Sample surrounding pixels
                vec4 chk_col = texture2D(gm_BaseTexture, chk_pos);    
                
                // Same inverted condition logic
                if (chk_col.a > tolerance ^^ in_line) {
                    
                    // Check if the UV is still in the sprite area
                    bool out_bound = (chk_pos.x < u_uv.r || chk_pos.y < u_uv.g || 
                                      chk_pos.x > u_uv.b || chk_pos.y > u_uv.a);
                    
                    vec2 offset = (chk_pos - v_vTexcoord) / u_pixel_size;
                    vec2 normalized_offset = offset / thickness;
                    float dist = dot(normalized_offset, normalized_offset);
                    
                    if (dist <= 2.0 - roundness && !out_bound) {
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
    
    // Define the final fragment color as the sampled texture or the outline color
    gl_FragColor = mix(v_vColour * frag_col, u_line_color, outline);
}
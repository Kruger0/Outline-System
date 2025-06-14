

//====================================================================
#region CONFIGURATION

//Default Settings  -  Change them if you want.

#macro OUTLINE_LINE_WIDTH       1.0
#macro OUTLINE_LINE_COLOR       c_black
#macro OUTLINE_LINE_ALPHA       1.0
#macro OUTLINE_TOLERANCE        0.0
#macro OUTLINE_RESOLUTION       1.0
#macro OUTLINE_ROUNDNESS        0.0
#macro OUTLINE_UV_BOUND_MODE    true
#macro OUTLINE_CACHE_TEX_SIZE   64

#endregion
//====================================================================


//====================================================================
#region SYSTEM START

/// @ignore
function __ol_cache() {
    static data = undefined;
    data ??= {    
        config: {
            line_width      : OUTLINE_LINE_WIDTH,
            line_col        : OUTLINE_LINE_COLOR,
            line_alpha      : OUTLINE_LINE_ALPHA,
            tolerance       : OUTLINE_TOLERANCE,
            resolution      : OUTLINE_RESOLUTION,
            roundness       : OUTLINE_ROUNDNESS,
            uv_bound_mode   : OUTLINE_UV_BOUND_MODE,
        },
    
        shader_supported    : false,
        shader_compiled     : false,
        support_traced      : false,
        compile_traced      : false,
            
        uniforms: {
            line_color      : shader_get_uniform(__shd_outline, "u_line_color"),
            pixel_size      : shader_get_uniform(__shd_outline, "u_pixel_size"),
            thk_rn_tol      : shader_get_uniform(__shd_outline, "u_thk_rn_tol"),
            uv              : shader_get_uniform(__shd_outline, "u_uv"),
        },
    
        surface_mng: {
            cache           : [],
            structs         : [],
            meta            : [],
            test_index      : 0,
        },
            
        tracer: {
            not_supported   : "[OUTLINE] - Error: Shaders are not supported in this hardware",
            not_compiled    : "[OUTLINE] - Error: Main shader could not be compiled on this hardware",
        },
    };
    return data;
}


if (shaders_are_supported()) {
    __ol_cache().shader_supported = true;
    if (shader_is_compiled(__shd_outline)) {
        __ol_cache().shader_compiled = true;
    } else {
        show_debug_message(__ol_cache().tracer.not_compiled);
        __ol_cache().compile_traced = true;
    }
} else {
    show_debug_message(__ol_cache().tracer.not_supported);
    __ol_cache().support_traced = true;
}


#endregion
//====================================================================


//====================================================================
#region INTERTAL

/// @ignore
function __outline_set_shader() {
    if (__ol_cache().shader_compiled) {
        if (shader_current() != __shd_outline) {
            shader_set(__shd_outline);
        }
    } else {
        if (!__ol_cache().compile_traced) {
            show_debug_message(__ol_cache().tracer.not_compiled);
            __ol_cache().compile_traced = true;
        }
    }
};


/// @ignore
function __outline_set_uniforms(_texture, _uv, _thick, _col, _alpha, _tol, _res, _round, _uv_bnd) {
    static uniforms = __ol_cache().uniforms;
    var _w  = texture_get_texel_width(_texture);
    var _h  = texture_get_texel_height(_texture);
    
    shader_set_uniform_f(uniforms.line_color, 
        ((_col)       & 0xFF) / 255.0,
        ((_col >> 8)  & 0xFF) / 255.0,
        ((_col >> 16) & 0xFF) / 255.0,
        _alpha
    );
        
    shader_set_uniform_f(uniforms.pixel_size, _w*(1.0/_res), _h*(1.0/_res));
    shader_set_uniform_f(uniforms.thk_rn_tol, _thick*_res, _round, _tol);
    shader_set_uniform_f(uniforms.uv, _uv[0], _uv[1], _uv[2], _uv[3]);
};


/// @ignore
function __outline_surface_create(_wid, _hei) {
    var _surf = surface_create(_wid, _hei);
    
    var _struct = {surf: _surf};
    array_push(__ol_cache().surface_mng.structs, weak_ref_create(_struct));
    
    var _meta = {surf: _surf};
    array_push(__ol_cache().surface_mng.meta, _meta);
    
    return _struct;
}


/// @ignore
function __outline_surface_get(_wid, _hei) {
    var _mng        = __ol_cache().surface_mng;
    var _array      = _mng.cache;
    var _index      = 0;
    var _surf       = -1;
    var _my_surf    = -1;
    var _surf_found = false;

    for (var i = 0, _len = array_length(_array); i < _len; i++) {
        _index = _array[i];
        if (is_struct(_index)) {
            _surf = _index.surf;
            if (surface_exists(_surf)) {
                if (surface_get_width(_surf) >= _wid && surface_get_height(_surf) >= _hei) {
                    _my_surf    = _index;
                    _surf_found = true;
                }
            }
        }
    }
    
    if !(_surf_found) {
        _my_surf = __outline_surface_create(max(_wid, OUTLINE_CACHE_TEX_SIZE), max(_hei, OUTLINE_CACHE_TEX_SIZE));
        array_push(_array, _my_surf);
    }
    
    return _my_surf.surf;
}
  
  
/// @ignore
function __outline_gc() {
    // Method originaly created by JujuAdams
    // After the global cache this is kind of unnecessary but anyways...
    var _mng = __ol_cache().surface_mng;
    var _size = array_length(_mng.structs);
    
    if (_size > 0) {
        
        var i = _mng.test_index;
        repeat(min(4, _size)) { // Max iterarions per step
            if (weak_ref_alive(_mng.structs[i])) {
                i = (i + 1) mod _size;
            } else {
                var _surf = _mng.meta[i].surf;
                                
                if (_surf != application_surface) {
                    if (surface_exists(_surf)) {
                        surface_free(_surf);
                        show_debug_message($"[OUTLINE] - Surface {_surf} free from memory!");
                    }
                }
                
                array_delete(_mng.structs, i, 1);
                array_delete(_mng.meta, i, 1);
                --_size;
                
                if (_size > 0) {
                    i = i mod _size;
                } else {
                    i = 0;
                }
            }
        }
        _mng.test_index = i;
    }
}

call_later(1, time_source_units_seconds, __outline_gc, true);

#endregion
//====================================================================


//====================================================================
#region GENERAL


/// @desc    Reset the default shader.
function outline_end() {
    if (shader_current() == __shd_outline) {
        shader_reset();
    }
};


/// @desc               Create a configuration struct for the outline.
/// @arg [line_width]   The thickness, in pixels, of the outline.
/// @arg [line_col]     The color of the outline.
/// @arg [line_alpha]   The alpha of the outline.
/// @arg [roundness]    The roundess factor of the outline.
/// @arg [tolerance]    The minimum alpha value a pixel need to become an outline.
/// @arg [resolution]   The resolution of the outline.
/// @arg [uv_bound]     Locks the shader on the sprite uv.
function ol_config(_width, _col, _alpha, _round, _tol, _res, _uv_bnd) {
    static config =  __ol_cache().config
    return {
        line_width      : _width    ?? config.line_width,
        line_col        : _col      ?? config.line_col,
        line_alpha      : _alpha    ?? config.line_alpha,
        roundness       : _round    ?? config.roundness,
        tolerance       : _tol      ?? config.tolerance,
        resolution      : _res      ?? config.resolution,
        uv_bound_mode   : _uv_bnd   ?? config.uv_bound_mode,
    }
}


/// @desc               Set a default configuration struct for the outline.
/// @arg [line_width]   The thickness, in pixels, of the outline.
/// @arg [line_col]     The color of the outline.
/// @arg [line_alpha]   The alpha of the outline.
/// @arg [roundness]    The roundess factor of the outline.
/// @arg [tolerance]    The minimum alpha value a pixel need to become an outline.
/// @arg [resolution]   The resolution of the outline.
/// @arg [uv_bound]     Locks the shader on the sprite uv.
function outline_set_config(_width, _col, _alpha, _round, _tol, _res, _uv_bnd) {
    with (__ol_cache().config) {
        line_width      = _width    ?? line_width;
        line_col        = _col      ?? line_col;
        line_alpha      = _alpha    ?? line_alpha;
        roundness       = _round    ?? roundness;
        tolerance       = _tol      ?? tolerance;
        resolution      = _res      ?? resolution;
        uv_bound_mode   = _uv_bnd   ?? uv_bound_mode;
    }
}


#endregion
//====================================================================


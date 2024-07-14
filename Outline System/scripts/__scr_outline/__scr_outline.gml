

//====================================================================
#region SYSTEM START

	/// @ignore
	function __ol_cache() {
		static data = {
		
			//Default Settings  -  Change them if you want.
			config: {
				line_width		: 1.0,		// line_width
				line_col		: #000000,	// line_col
				line_alpha		: 1.0,		// line_alpha
				tolerance		: 0.0,		// tolerance
				resolution		: 1.0,		// resolution
				roundness		: 0.0,		// roundness
				uv_bound_mode	: true,		// uv_bound_mode
			},
	
			shader_supported	: false,
			shader_compiled		: false,
			support_traced		: false,
			compile_traced		: false,
	
			surface_mng: {
				structs		: [],
				meta		: [],
				test_index	: 0,
			},
			
			tracer: {
				not_supported	: @"
=============================================================================
Outline System Error: Shaders are not supported in this hardware
=============================================================================
	",
				not_compiled	: @"
=============================================================================
Outline System Error: Main shader could not be compiled on this hardware
=============================================================================
	",
			},
		};
	
		return data;
	}


	if (shaders_are_supported()) {
		__ol_cache().shader_supported = true;
		if (shader_is_compiled(__shd_outline)) {
			__ol_cache().shader_compiled = true;
		} else {
			show_debug_message(__ol_cache().tracer.not_compiled)
	__ol_cache().compile_traced = true;
		}
	} else {
		show_debug_message(__ol_cache().tracer.not_supported)
	__ol_cache().support_traced = true;
	}


#endregion
//====================================================================


//====================================================================
#region INTERTAL

	/// @ignore
	function __outline_init() {	
		if (is_undefined(self[$ "__outline_uniforms_initiated"])) {
			__u_outline_line_color	= shader_get_uniform(__shd_outline, "u_line_color");
			__u_outline_pixel_size	= shader_get_uniform(__shd_outline, "u_pixel_size");
			__u_outline_thk_rn_tol	= shader_get_uniform(__shd_outline, "u_thk_rn_tol")
			__u_outline_uv			= shader_get_uniform(__shd_outline, "u_uv");
				
			self[$ "__outline_uniforms_initiated"] = true;
		};
	};

	/// @ignore
	function __outline_start() {
		if (__ol_cache().shader_compiled) {
			if (shader_current() != __shd_outline) {
				shader_set(__shd_outline)
			}
		} else {
			if (!__ol_cache().compile_traced) {
				show_debug_message(__ol_cache().tracer.not_compiled)
				__ol_cache().compile_traced = true;
			}
			
		}
	};

	/// @ignore
	function __outline_set_uniforms(_texture, _uv, _thick, _col, _alpha, _tol, _res, _round, _uv_bnd) {
	
		var _w = texture_get_texel_width(_texture);
		var _h = texture_get_texel_height(_texture);
	
		var _color = [
			((_col) & 0xFF)			/ 255,
	        ((_col >> 8) & 0xFF)	/ 255,
	        ((_col >> 16) & 0xFF)	/ 255,
			_alpha,
		];
	
		shader_set_uniform_f_array(__u_outline_line_color, _color);
		shader_set_uniform_f_array(__u_outline_pixel_size, [_w*(1.0/_res), _h*(1.0/_res)]);
		shader_set_uniform_f(__u_outline_thk_rn_tol, _thick*_res, _round, _tol)
		shader_set_uniform_f(__u_outline_uv, _uv[0], _uv[1], _uv[2], _uv[3]);
	};

	/// @ignore
	function __outline_surface_create(_wid, _hei) {
		var _surf = surface_create(_wid, _hei)
	
	    var _struct = {surf: _surf};
	    array_push(__ol_cache().surface_mng.structs, weak_ref_create(_struct));
    
	    var _meta = {surf: _surf};
	    array_push(__ol_cache().surface_mng.meta, _meta);
    
	    return _struct;
	}

	/// @ignore
	function __outline_surface_get(_wid, _hei) {
		_ol_surf_array = self[$ "_ol_surf_array"] ?? [];
	
		var _index = 0
		var _surf = -1
		var _my_surf = -1
		var _surf_found = false

		for (var i = 0, _len = array_length(_ol_surf_array); i < _len; i++) {
			_index = _ol_surf_array[i]
			if (is_struct(_index)) {
				_surf = _index.surf
				if (surface_exists(_surf)) {
					if (surface_get_width(_surf) >= _wid && surface_get_height(_surf) >= _hei) {
						_my_surf = _index
						_surf_found = true
					}
				}
			}
		}
	
		if !(_surf_found) {
			_my_surf = __outline_surface_create(_wid, _hei)
			array_push(_ol_surf_array, _my_surf)
		}
	
		return _my_surf.surf;
	}

	/// @ignore
	function __outline_gc() {
	
		// Method originaly created by JujuAdams
		var _mng = __ol_cache().surface_mng;
	    var _size = array_length(_mng.structs);
	
	    if (_size > 0) {
		
	        var i = _mng.test_index;
	        repeat(min(10, _size)) { // Max iterarions per step
	            if (weak_ref_alive(_mng.structs[i])) {
	                i = (i + 1) mod _size;
	            } else {
	                var _surf = _mng.meta[i].surf;
								
	                if (_surf != application_surface) {
	                    if (surface_exists(_surf)) {
	                        surface_free(_surf);
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

	var _ts = time_source_create(time_source_global, 1, time_source_units_frames, __outline_gc, [], -1)
	time_source_start(_ts)

#endregion
//====================================================================


//====================================================================
#region GENERAL


/// @desc	Reset the default shader.
function outline_end() {
	shader_reset();
};


/// @desc	Create a configuration struct for the outline.
/// @arg [line_width]	= The thickness, in pixels, of the outline.
/// @arg [line_col]		= The color of the outline.
/// @arg [line_alpha]	= The alpha of the outline.
/// @arg [roundness]	= The roundess factor of the outline.
/// @arg [tolerance]	= The minimum alpha value a pixel need to become an outline.
/// @arg [resolution]	= The resolution of the outline.
/// @arg [uv_bound]		= Locks the shader on the sprite uv.
function ol_config(_width, _col, _alpha, _round, _tol, _res, _uv_bnd) {
	
	return {
		line_width		: _width	?? __ol_cache().config.line_width,
		line_col		: _col		?? __ol_cache().config.line_col,
		line_alpha		: _alpha	?? __ol_cache().config.line_alpha,
		roundness		: _round	?? __ol_cache().config.roundness,
		tolerance		: _tol		?? __ol_cache().config.tolerance,
		resolution		: _res		?? __ol_cache().config.resolution,
		uv_bound_mode	: _uv_bnd	?? __ol_cache().config.uv_bound_mode,
	}
}


#endregion
//====================================================================


//====================================================================
#region TEXT FUNCTIONS


/// @desc	Set the outline shader for the next draw texts.
/// @arg [ol_config]	= The configuration struct for the outline. Use ol_config() to generate it.
function outline_set_text(_ol_config = ol_config()) {
	var _thick	= _ol_config.line_width
	var _col	= _ol_config.line_col
	var _alpha	= _ol_config.line_alpha
	var _round	= _ol_config.roundness
	var _tol	= _ol_config.tolerance
	var _res	= _ol_config.resolution
	var _uv_bnd = _ol_config.uv_bound_mode
		
	__outline_init();
	__outline_start();
	var _font = draw_get_font();
	var _texture = font_get_texture(_font);

	var _uv = _uv_bnd ? font_get_uvs(_font) : [0.0, 0.0, 1.0, 1.0];
	__outline_set_uniforms(_texture, _uv, _thick, _col, _alpha, _tol, _res, _round, _uv);
}


/// @desc	Create a baked sprite with an string outlined.
/// @arg font			= The font that will be used with the outline.
/// @arg string			= The string to be writen.
/// @arg colour			= The color of the string.
/// @arg alpha			= The alpha of the string.
/// @arg [ol_config]	= The configuration struct for the outline. Use ol_config() to generate it.
function outline_bake_sprite_text(_font, _string, _str_col, _str_alpha, _ol_config = ol_config()) {
	var _thick	= _ol_config.line_width
	var _col	= _ol_config.line_col
	var _alpha	= _ol_config.line_alpha
	var _round	= _ol_config.roundness
	var _tol	= _ol_config.tolerance
	var _res	= _ol_config.resolution
	var _uv_bnd = _ol_config.uv_bound_mode
	
	var _cur_font = draw_get_font();
	var _cur_shad = shader_current();
	
	if (_cur_font != _font) {
		draw_set_font(_font);
	}
	if (_cur_shad) {
		shader_reset();
	}
		
	var _halign = draw_get_halign();
	var _valign = draw_get_valign();
	var _str_w = string_width(_string);
	var _str_h = string_height(_string);
	var _xx = 0;
	var _yy = 0;
	
	switch (_halign) {
		case fa_center: {_xx = _str_w*0.5}	break;
		case fa_right:  {_xx = _str_w}		break;
	}
	switch (_valign) {
		case fa_middle: {_yy = _str_h*0.5}	break;
		case fa_bottom: {_yy = _str_h}		break;
	}
	
	var _gap = max(_thick, 0);
	var _wid = _str_w+(_gap*2);
	var _hei = _str_h+(_gap*2);
	var _surf1, _surf2, _surf_spr;
	
	_surf1= surface_create(_wid, _hei);
	surface_set_target(_surf1);
		draw_clear_alpha(0, 0);
		draw_text(_xx+_gap, _yy+_gap, _string);
	surface_reset_target();
	
	_surf2 = surface_create(_wid, _hei)
	outline_set_surface(_surf2, _ol_config);
	surface_set_target(_surf2);
		draw_clear_alpha(0, 0);
		gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
		draw_surface_ext(_surf1, 0, 0, 1, 1, 0, _str_col, _str_alpha);
		gpu_set_blendmode(bm_normal);
	surface_reset_target();
	outline_end();
	
	_surf_spr = sprite_create_from_surface(_surf2, 0, 0, _wid, _hei, false, false, _gap+_xx, _gap+_yy);
	
	if (_cur_font != _font) {
		draw_set_font(_cur_font);
	}
	if (_cur_shad) {
		shader_set(_cur_shad);
	}
	
	surface_free(_surf1);
	surface_free(_surf2);
	
	return _surf_spr;
}


/// @desc	Create a baked sprite with an string outlined with extra formating.
/// @arg font			= The font that will be used with the outline.
/// @arg string			= The string to be writen.
/// @arg sep			= The distance in pixels between lines of text.
/// @arg w				= The maximum withd in pixels of the string before a line break.
/// @arg colour			= The color of the string.
/// @arg alpha			= The alpha of the string.
/// @arg [ol_config]	= The configuration struct for the outline. Use ol_config() to generate it.
function outline_bake_sprite_text_ext(_font, _string, _sep, _w, _str_col, _str_alpha, _ol_config = ol_config()) {
	var _thick	= _ol_config.line_width
	var _col	= _ol_config.line_col
	var _alpha	= _ol_config.line_alpha
	var _round	= _ol_config.roundness
	var _tol	= _ol_config.tolerance
	var _res	= _ol_config.resolution
	var _uv_bnd = _ol_config.uv_bound_mode
	
	var _cur_font = draw_get_font();
	var _cur_shad = shader_current();
	
	if (_cur_font != _font) {
		draw_set_font(_font);
	}
	if (_cur_shad) {
		shader_reset();
	}
		
	var _halign = draw_get_halign();
	var _valign = draw_get_valign();
	
	var _extra_lines = 4;
	var _gap = max(_thick, 0);
	var _str_w = string_width(_string);
	var _lines = floor(_str_w/_w);
	var _wid = (_str_w/_lines)+(2*_gap);
	var _hei = ((_lines+_extra_lines)*_sep)+(2*_gap);
	var _surf1, _surf2, _surf_spr;
	
	var _xx = 0;
	var _yy = 0;
	
	switch (_halign) {
		case fa_center: {_xx = (_str_w/_lines)*0.5}	break;
		case fa_right:  {_xx = (_str_w/_lines)}		break;
	}
	switch (_valign) {
		case fa_middle: {_yy = ((_lines+_extra_lines)*_sep)*0.5}	break;
		case fa_bottom: {_yy = ((_lines+_extra_lines)*_sep)	}		break;
	}
	
	_surf1= surface_create(_wid, _hei);
	surface_set_target(_surf1);
		draw_clear_alpha(0, 0);
		draw_text_ext(_xx+_gap, _yy+_gap, _string, _sep, _w);
	surface_reset_target();
	
	_surf2 = surface_create(_wid, _hei)
	outline_set_surface(_surf2, _ol_config);
	surface_set_target(_surf2);
		draw_clear_alpha(0, 0);	
		gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
		draw_surface_ext(_surf1, 0, 0, 1, 1, 0, _str_col, _str_alpha);
		gpu_set_blendmode(bm_normal)
	surface_reset_target();
	outline_end();
	
	_surf_spr = sprite_create_from_surface(_surf2, 0, 0, _wid, _hei, false, false, _gap+_xx, _gap+_yy);
	
	if (_cur_font != _font) {
		draw_set_font(_cur_font);
	}
	if (_cur_shad) {
		shader_set(_cur_shad);
	}
	
	surface_free(_surf1);
	surface_free(_surf2);
	
	return _surf_spr;
}


/// @desc	Draw an outlined text.
/// @arg x				= The X coordinate of the text.
/// @arg y				= The Y coordinate of the text.
/// @arg string			= The string to be drawed.
/// @arg [ol_config]	= The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_text(_x, _y, _string, _ol_config = ol_config()) {
	var _thick	= _ol_config.line_width
		
	var _halign = draw_get_halign();
	var _valign = draw_get_valign();
	var _str_w	= string_width(_string);
	var _str_h	= string_height(_string);
	var _xx = 0;
	var _yy = 0;
	
	switch (_halign) {
		case fa_center: {_xx = _str_w*0.5}	break;
		case fa_right:  {_xx = _str_w}		break;
	}
	switch (_valign) {
		case fa_middle: {_yy = _str_h*0.5}	break;
		case fa_bottom: {_yy = _str_h}		break;
	}
	
	var _gap = max(_thick, 0);	
	var _wid = _str_w+(2*_gap);
	var _hei = _str_h+(2*_gap);
	
	var _surf = __outline_surface_get(_wid, _hei);

	surface_set_target(_surf);
		draw_clear_alpha(0, 0);
		var _cur_shader = shader_current();
		shader_reset();
		draw_text(_xx+_gap, _yy+_gap, _string);
		shader_set(_cur_shader);
	surface_reset_target();
	
	outline_draw_surface(_surf, _x-(_gap+_xx), _y-(_gap+_yy), _ol_config);
	outline_end();
}


/// @desc	Draw an outlined text with extra formating.
/// @arg x				= The X coordinate of the text.
/// @arg y				= The Y coordinate of the text.
/// @arg string			= The string to be drawed.
/// @arg sep			= The distance in pixels between lines of text.
/// @arg w				= The maximum withd in pixels of the string before a line break.
/// @arg [ol_config]	= The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_text_ext(_x, _y, _string, _sep, _w, _ol_config = ol_config()) {
	var _thick	= _ol_config.line_width
		
	var _halign = draw_get_halign();
	var _valign = draw_get_valign();

	var _extra_lines = 1;
	var _gap = max(_thick, 0);
	var _str_w = string_width(_string);
	var _lines = max(floor(_str_w/_w), 1);
	var _wid = floor(_str_w/_lines)+(2*_gap);
	var _hei = ((_lines+_extra_lines)*_sep)+(2*_gap);
	
	var _xx = 0;
	var _yy = 0;
	
	switch (_halign) {
		case fa_center: {_xx = (_str_w/_lines)*0.5}	break;
		case fa_right:  {_xx = (_str_w/_lines)}		break;
	}
	switch (_valign) {
		case fa_middle: {_yy = ((_lines+_extra_lines)*_sep)*0.5}	break;
		case fa_bottom: {_yy = ((_lines+_extra_lines)*_sep)	}		break;
	}
	
	var _surf = __outline_surface_get(_wid, _hei);

	surface_set_target(_surf);
		draw_clear_alpha(0, 0);
		var _cur_shader = shader_current();
		shader_reset();
		draw_text_ext(_xx+_gap, _yy+_gap, _string, _sep, _w);
		shader_set(_cur_shader);
	surface_reset_target();
	
	outline_draw_surface(_surf, _x-(_gap+_xx), _y-(_gap+_yy), _ol_config);
}


/// @desc	Draw an outlined text with transformations.
/// @arg x				= The X coordinate of the text.
/// @arg y				= The Y coordinate of the text.
/// @arg string			= The string to be drawed.
/// @arg xscale			= The horizontal scale of the string.
/// @arg yscale			= The vertical scale of the string.
/// @arg angle			= The angle of the string.
/// @arg [ol_config]	= The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_text_transformed(_x, _y, _string, _xscal, _yscal, _ang, _ol_config = ol_config()) {
	var _thick	= _ol_config.line_width
		
	var _halign = draw_get_halign();
	var _valign = draw_get_valign();
	var _str_w	= string_width(_string);
	var _str_h	= string_height(_string);
	var _xx = 0;
	var _yy = 0;
	
	switch (_halign) {
		case fa_center: {_xx = _str_w*0.5}	break;
		case fa_right:  {_xx = _str_w}		break;
	}
	switch (_valign) {
		case fa_middle: {_yy = _str_h*0.5}	break;
		case fa_bottom: {_yy = _str_h}		break;
	}
	
	var _gap = max(_thick, 0);	
	var _wid = _str_w+(2*_gap);
	var _hei = _str_h+(2*_gap);
	
	var _surf = __outline_surface_get(_wid, _hei);

	surface_set_target(_surf);
		draw_clear_alpha(0, 0);
		var _cur_shader = shader_current();
		shader_reset();
		draw_text(_xx+_gap, _yy+_gap, _string);
		shader_set(_cur_shader);
	surface_reset_target();
	
	outline_draw_surface_ext(_surf, _x-(_gap+_xx)*_xscal, _y-(_gap+_yy)*_yscal, _xscal, _yscal, _ang, c_white, 1.0, _ol_config);
	outline_end();
}


/// @desc	Draw an outlined text with color.
/// @arg x				= The X coordinate of the text.
/// @arg y				= The Y coordinate of the text.
/// @arg string			= The string to be drawed.
/// @arg c1				= The colour for the top left of the drawn text.
/// @arg c2				= The colour for the top right of the drawn text.
/// @arg c3				= The colour for the bottom left of the drawn text.
/// @arg c4				= The colour for the bottom right of the drawn text.
/// @arg alpha			= The alpha of the string.
/// @arg [ol_config]	= The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_text_color(_x, _y, _string, _c1, _c2 = _c1, _c3 = _c1, _c4 = _c1, _a, _ol_config = ol_config()) {
	var _thick	= _ol_config.line_width
		
	var _halign = draw_get_halign();
	var _valign = draw_get_valign();
	var _str_w	= string_width(_string);
	var _str_h	= string_height(_string);
	var _xx = 0;
	var _yy = 0;
	
	switch (_halign) {
		case fa_center: {_xx = _str_w*0.5}	break;
		case fa_right:  {_xx = _str_w}		break;
	}
	switch (_valign) {
		case fa_middle: {_yy = _str_h*0.5}	break;
		case fa_bottom: {_yy = _str_h}		break;
	}
	
	var _gap = max(_thick, 0);	
	var _wid = _str_w+(2*_gap);
	var _hei = _str_h+(2*_gap);
	
	var _surf = __outline_surface_get(_wid, _hei);

	surface_set_target(_surf);
		draw_clear_alpha(0, 0);
		var _cur_shader = shader_current();
		shader_reset();
		draw_text_color(_xx+_gap, _yy+_gap, _string, _c1, _c2, _c3, _c4, 1.0);
		shader_set(_cur_shader);
	surface_reset_target();
	
	outline_draw_surface_ext(_surf, _x-(_gap+_xx), _y-(_gap+_yy), 1, 1, 0, c_white, _a, _ol_config);
	outline_end();
}


/// @desc	Draw an outlined text with extra formating.
/// @arg x				= The X coordinate of the text.
/// @arg y				= The Y coordinate of the text.
/// @arg string			= The string to be drawed.
/// @arg sep			= The distance in pixels between lines of text.
/// @arg w				= The maximum withd in pixels of the string before a line break.
/// @arg xscale			= The horizontal scale of the string.
/// @arg yscale			= The vertical scale of the string.
/// @arg angle			= The angle of the string.
/// @arg [ol_config]	= The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_text_ext_transformed(_x, _y, _string, _sep, _w, _xscal, _yscal, _ang, _ol_config = ol_config()) {
	var _thick	= _ol_config.line_width
		
	var _halign = draw_get_halign();
	var _valign = draw_get_valign();

	var _extra_lines = 1;
	var _gap = max(_thick, 0);
	var _str_w = string_width(_string);
	var _lines = max(floor(_str_w/_w), 1);
	var _wid = floor(_str_w/_lines)+(2*_gap);
	var _hei = ((_lines+_extra_lines)*_sep)+(2*_gap);
	
	var _xx = 0;
	var _yy = 0;
	
	switch (_halign) {
		case fa_center: {_xx = (_str_w/_lines)*0.5}	break;
		case fa_right:  {_xx = (_str_w/_lines)}		break;
	}
	switch (_valign) {
		case fa_middle: {_yy = ((_lines+_extra_lines)*_sep)*0.5}	break;
		case fa_bottom: {_yy = ((_lines+_extra_lines)*_sep)	}		break;
	}
	
	var _surf = __outline_surface_get(_wid, _hei);

	surface_set_target(_surf);
		draw_clear_alpha(0, 0);
		var _cur_shader = shader_current();
		shader_reset();
		draw_text_ext(_xx+_gap, _yy+_gap, _string, _sep, _w);
		shader_set(_cur_shader);
	surface_reset_target();
	
	outline_draw_surface_ext(_surf, _x-(_gap+_xx)*_xscal, _y-(_gap+_yy)*_yscal, _xscal, _yscal, _ang, c_white, 1.0, _ol_config);
}


/// @desc	Draw an outlined text with transformations and color.
/// @arg x				= The X coordinate of the text.
/// @arg y				= The Y coordinate of the text.
/// @arg string			= The string to be drawed.
/// @arg xscale			= The horizontal scale of the string.
/// @arg yscale			= The vertical scale of the string.
/// @arg angle			= The angle of the string.
/// @arg c1				= The colour for the top left of the drawn text.
/// @arg c2				= The colour for the top right of the drawn text.
/// @arg c3				= The colour for the bottom left of the drawn text.
/// @arg c4				= The colour for the bottom right of the drawn text.
/// @arg alpha			= The alpha of the string.
/// @arg [ol_config]	= The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_text_transformed_color(_x, _y, _string, _xscal, _yscal, _ang, _c1, _c2 = _c1, _c3 = _c1, _c4 = _c1, _a, _ol_config = ol_config()) {
	var _thick	= _ol_config.line_width
		
	var _halign = draw_get_halign();
	var _valign = draw_get_valign();
	var _str_w	= string_width(_string);
	var _str_h	= string_height(_string);
	var _xx = 0;
	var _yy = 0;
	
	switch (_halign) {
		case fa_center: {_xx = _str_w*0.5}	break;
		case fa_right:  {_xx = _str_w}		break;
	}
	switch (_valign) {
		case fa_middle: {_yy = _str_h*0.5}	break;
		case fa_bottom: {_yy = _str_h}		break;
	}
	
	var _gap = max(_thick, 0);	
	var _wid = _str_w+(2*_gap);
	var _hei = _str_h+(2*_gap);
	
	var _surf = __outline_surface_get(_wid, _hei);

	surface_set_target(_surf);
		draw_clear_alpha(0, 0);
		var _cur_shader = shader_current();
		shader_reset();
		draw_text_color(_xx+_gap, _yy+_gap, _string, _c1, _c2, _c3, _c4, 1.0);
		shader_set(_cur_shader);
	surface_reset_target();
	
	outline_draw_surface_ext(_surf, _x-(_gap+_xx)*_xscal, _y-(_gap+_yy)*_yscal, _xscal, _yscal, _ang, c_white, _a, _ol_config);
	outline_end();
}


/// @desc	Draw an outlined text with extra formating.
/// @arg x				= The X coordinate of the text.
/// @arg y				= The Y coordinate of the text.
/// @arg string			= The string to be drawed.
/// @arg sep			= The distance in pixels between lines of text.
/// @arg w				= The maximum withd in pixels of the string before a line break.
/// @arg c1				= The colour for the top left of the drawn text.
/// @arg c2				= The colour for the top right of the drawn text.
/// @arg c3				= The colour for the bottom left of the drawn text.
/// @arg c4				= The colour for the bottom right of the drawn text.
/// @arg alpha			= The alpha of the string.
/// @arg [ol_config]	= The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_text_ext_color(_x, _y, _string, _sep, _w, _c1, _c2 = _c1, _c3 = _c1, _c4 = _c1, _a, _ol_config = ol_config()) {
	var _thick	= _ol_config.line_width
		
	var _halign = draw_get_halign();
	var _valign = draw_get_valign();

	var _extra_lines = 1;
	var _gap = max(_thick, 0);
	var _str_w = string_width(_string);
	var _lines = max(floor(_str_w/_w), 1);
	var _wid = floor(_str_w/_lines)+(2*_gap);
	var _hei = ((_lines+_extra_lines)*_sep)+(2*_gap);
	
	var _xx = 0;
	var _yy = 0;
	
	switch (_halign) {
		case fa_center: {_xx = (_str_w/_lines)*0.5}	break;
		case fa_right:  {_xx = (_str_w/_lines)}		break;
	}
	switch (_valign) {
		case fa_middle: {_yy = ((_lines+_extra_lines)*_sep)*0.5}	break;
		case fa_bottom: {_yy = ((_lines+_extra_lines)*_sep)	}		break;
	}
	
	var _surf = __outline_surface_get(_wid, _hei);

	surface_set_target(_surf);
		draw_clear_alpha(0, 0);
		var _cur_shader = shader_current();
		shader_reset();
		draw_text_ext_color(_xx+_gap, _yy+_gap, _string, _sep, _w, _c1, _c2, _c3, _c4, 1.0);
		shader_set(_cur_shader);
	surface_reset_target();
	
	outline_draw_surface_ext(_surf, _x-(_gap+_xx), _y-(_gap+_yy), 1, 1, 0, c_white, _a, _ol_config);
}


/// @desc	Draw an outlined text with extra formating.
/// @arg x				= The X coordinate of the text.
/// @arg y				= The Y coordinate of the text.
/// @arg string			= The string to be drawed.
/// @arg sep			= The distance in pixels between lines of text.
/// @arg w				= The maximum withd in pixels of the string before a line break.
/// @arg xscale			= The horizontal scale of the string.
/// @arg yscale			= The vertical scale of the string.
/// @arg angle			= The angle of the string.
/// @arg c1				= The colour for the top left of the drawn text.
/// @arg c2				= The colour for the top right of the drawn text.
/// @arg c3				= The colour for the bottom left of the drawn text.
/// @arg c4				= The colour for the bottom right of the drawn text.
/// @arg alpha			= The alpha of the string.
/// @arg [ol_config]	= The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_text_ext_transformed_color(_x, _y, _string, _sep, _w, _xscal, _yscal, _ang, _c1, _c2 = _c1, _c3 = _c1, _c4 = _c1, _a, _ol_config = ol_config()) {
	var _thick	= _ol_config.line_width
		
	var _halign = draw_get_halign();
	var _valign = draw_get_valign();

	var _extra_lines = 1;
	var _gap = max(_thick, 0);
	var _str_w = string_width(_string);
	var _lines = max(floor(_str_w/_w), 1);
	var _wid = floor(_str_w/_lines)+(2*_gap);
	var _hei = ((_lines+_extra_lines)*_sep)+(2*_gap);
	
	var _xx = 0;
	var _yy = 0;
	
	switch (_halign) {
		case fa_center: {_xx = (_str_w/_lines)*0.5}	break;
		case fa_right:  {_xx = (_str_w/_lines)}		break;
	}
	switch (_valign) {
		case fa_middle: {_yy = ((_lines+_extra_lines)*_sep)*0.5}	break;
		case fa_bottom: {_yy = ((_lines+_extra_lines)*_sep)	}		break;
	}
	
	var _surf = __outline_surface_get(_wid, _hei);

	surface_set_target(_surf);
		draw_clear_alpha(0, 0);
		var _cur_shader = shader_current();
		shader_reset();
		draw_text_ext_color(_xx+_gap, _yy+_gap, _string, _sep, _w, _c1, _c2, _c3, _c4, 1.0);
		shader_set(_cur_shader);
	surface_reset_target();
	
	outline_draw_surface_ext(_surf, _x-(_gap+_xx)*_xscal, _y-(_gap+_yy)*_yscal, _xscal, _yscal, _ang, c_white, _a, _ol_config);
}


#endregion
//====================================================================


//====================================================================
#region SPRITE FUNCTIONS


/// @desc	Set the outline shader for the next draw sprite.
/// @arg sprite			= The sprite to be drawned.
/// @arg subimg			= The subimg of the sprite to be used.
/// @arg [ol_config]	= The configuration struct for the outline. Use ol_config() to generate it.
function outline_set_sprite(_spr, _subimg, _ol_config = ol_config()) {
	var _thick	= _ol_config.line_width
	var _col	= _ol_config.line_col
	var _alpha	= _ol_config.line_alpha
	var _round	= _ol_config.roundness
	var _tol	= _ol_config.tolerance
	var _res	= _ol_config.resolution
	var _uv_bnd = _ol_config.uv_bound_mode
		
	__outline_init();
	__outline_start();
	var _texture = sprite_get_texture(_spr, _subimg);
	var _uv = _uv_bnd ? sprite_get_uvs(_spr, _subimg) : [0.0, 0.0, 1.0, 1.0];
	__outline_set_uniforms(_texture, _uv, _thick, _col, _alpha, _tol, _res, _round, _uv);
	return _spr;
}


/// @desc	Create a baked sprite with outline.
/// @arg sprite			= The sprite to be drawned.
/// @arg col			= The color of the sprite.
/// @arg alpha			= The alpha of the sprite.
/// @arg [ol_config]	= The configuration struct for the outline. Use ol_config() to generate it.
function outline_bake_sprite(_spr, _spr_col, _spr_alpha, _ol_config = ol_config()) {
	var _thick	= _ol_config.line_width
	
	var _cur_shad = shader_current();
	if (_cur_shad) {
		shader_reset();
	}
	
	var _gap = max(_thick, 0);
	var _wid = sprite_get_width(_spr)+_gap*2;
	var _hei = sprite_get_height(_spr)+_gap*2;
	var _x = sprite_get_xoffset(_spr);
	var _y = sprite_get_yoffset(_spr);
	
	var _surf1 = surface_create(_wid, _hei);
	var _surf2 = surface_create(_wid, _hei);
	var _surf_spr = -1;
	
	for (var i = 0, n = sprite_get_number(_spr); i < n; i++) {
		surface_set_target(_surf1);
			draw_clear_alpha(0, 0);
			gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
			draw_sprite(_spr, i, _x+_gap, _y+_gap);
			gpu_set_blendmode(bm_normal)
		surface_reset_target();
		
		outline_set_surface(_surf2, _ol_config);
		surface_set_target(_surf2);
			draw_clear_alpha(0, 0);
			gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
			draw_surface_ext(_surf1, 0, 0, 1, 1, 0, _spr_col, _spr_alpha);
			gpu_set_blendmode(bm_normal)
		surface_reset_target();
		outline_end();
		
		if !(sprite_exists(_surf_spr)) {
			_surf_spr = sprite_create_from_surface(_surf2, 0, 0, _wid, _hei, false, false, _gap, _gap);
		} else {
			sprite_add_from_surface(_surf_spr, _surf2, 0, 0, _wid, _hei, false, false);
		}
	}
	sprite_set_offset(_surf_spr, _x+_gap, _y+_gap);
	
	if (_cur_shad) {
		shader_set(_cur_shad);
	}
	
	surface_free(_surf1);
	surface_free(_surf2);
	
	return _surf_spr;
}


/// @desc	Draw an outlined sprite.
/// @arg sprite			= The sprite to be drawned.
/// @arg subimg			= The subimg of the sprite to be used.
/// @arg x				= The X coordinate of the sprite.
/// @arg y				= The Y coordinate of the sprite.
/// @arg [ol_config]	= The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_sprite(_spr, _subimg, _x, _y, _ol_config = ol_config()) {
	outline_set_sprite(_spr, _subimg, _ol_config);
	draw_sprite(_spr, _subimg, _x, _y);
	outline_end();
}


/// @desc	Draw an outlined sprite with extra formating.
/// @arg sprite			= The sprite to be drawned.
/// @arg subimg			= The subimg of the sprite to be used.
/// @arg x				= The X coordinate of the sprite.
/// @arg y				= The Y coordinate of the sprite.
/// @arg xscale			= The horizontal scaling of the sprite.
/// @arg yscale			= The vertical scaling of the sprite.
/// @arg rot			= The rotation of the sprite.
/// @arg colour			= The color of the sprite.
/// @arg alpha			= The alpha of the sprite.
/// @arg [ol_config]	= The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_sprite_ext(_spr, _subimg, _x, _y, _xscal, _yscal, _rot, _spr_col, _spr_alpha, _ol_config = ol_config()) {
	outline_set_sprite(_spr, _subimg, _ol_config);
	draw_sprite_ext(_spr, _subimg, _x, _y, _xscal, _yscal, _rot, _spr_col, _spr_alpha);
	outline_end();
}


#endregion
//====================================================================


//====================================================================
#region SURFACE FUNCTIONS


/// @desc	Set the outline shader for the next draw surface.
/// @arg surface_id		= The surface to be drawned.
/// @arg [ol_config]	= The configuration struct for the outline. Use ol_config() to generate it.
function outline_set_surface(_surf, _ol_config = ol_config()) {
	var _thick	= _ol_config.line_width
	var _col	= _ol_config.line_col
	var _alpha	= _ol_config.line_alpha
	var _round	= _ol_config.roundness
	var _tol	= _ol_config.tolerance
	var _res	= _ol_config.resolution
	var _uv_bnd = _ol_config.uv_bound_mode
		
	__outline_init();
	__outline_start();
	var _texture = surface_get_texture(_surf);
	var _uv = _uv_bnd ? texture_get_uvs(_texture) : [0.0, 0.0, 1.0, 1.0];
	__outline_set_uniforms(_texture, _uv, _thick, _col, _alpha, _tol, _res, _round, _uv);
	return _surf;
}


/// @desc	Draw an outlined surface.
/// @arg surface_id		= The surface to be drawned.
/// @arg x				= The X coordinate of the surface.
/// @arg y				= The Y coordinate of the surface.
/// @arg [ol_config]	= The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_surface(_surf, _x, _y, _ol_config = ol_config()) {
	outline_set_surface(_surf, _ol_config);
	draw_surface(_surf, _x, _y);
	outline_end();
}


/// @desc	Draw an outlined surface with extra formating.
/// @arg surface_id		= The surface to be drawned.
/// @arg x				= The X coordinate of the surface.
/// @arg y				= The Y coordinate of the surface.
/// @arg xscale			= The horizontal scaling of the surface.
/// @arg yscale			= The vertical scaling of the surface.
/// @arg rot			= The rotation of the surface.
/// @arg colour			= The color of the surface.
/// @arg alpha			= The alpha of the surface.
/// @arg [ol_config]	= The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_surface_ext(_surf, _x, _y, _xscal, _yscal, _rot, _surf_col, _surf_alpha, _ol_config = ol_config()) {
	outline_set_surface(_surf, _ol_config);
	draw_surface_ext(_surf, _x, _y, _xscal, _yscal, _rot, _surf_col, _surf_alpha);
	outline_end();
}


/// @desc	Draw an outlined surface with stretched dimensions.
/// @arg surface_id		= The surface to be drawned.
/// @arg x				= The X coordinate of the surface.
/// @arg y				= The Y coordinate of the surface.
/// @arg width			= The width at which to draw the surface.
/// @arg height			= The height at which to draw the surface.
/// @arg [ol_config]	= The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_surface_stretched(_surf, _x, _y, _wid, _hei, _ol_config = ol_config()) {
	outline_set_surface(_surf, _ol_config);
	draw_surface_stretched(_surf, _x, _y, _wid, _hei);
	outline_end();
}


#endregion
//====================================================================
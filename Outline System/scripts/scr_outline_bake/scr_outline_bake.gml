
/// @desc               Create a baked sprite with outline.
/// @arg sprite         The sprite to be draw.
/// @arg col            The color of the sprite.
/// @arg alpha          The alpha of the sprite.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_bake_sprite(_sprite, _spr_col, _spr_alpha, _ol_config = ol_config()) {
    var _thick  = _ol_config.line_width;
    
    var _cur_shad = shader_current();
    if (_cur_shad) {
        shader_reset();
    }
    
    var _gap    = max(_thick, 0);
    var _wid    = sprite_get_width(_sprite)+_gap*2;
    var _hei    = sprite_get_height(_sprite)+_gap*2;
    var _x      = sprite_get_xoffset(_sprite);
    var _y      = sprite_get_yoffset(_sprite);
    
    var _surf1  = surface_create(_wid, _hei);
    var _surf2  = surface_create(_wid, _hei);
    var _surf_spr = -1;
    
    for (var i = 0, n = sprite_get_number(_sprite); i < n; i++) {
        surface_set_target(_surf1);
            draw_clear_alpha(0, 0);
            gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
            draw_sprite(_sprite, i, _x+_gap, _y+_gap);
            gpu_set_blendmode(bm_normal)
        surface_reset_target();
        
        outline_set_surface(_surf2, _ol_config);
        surface_set_target(_surf2);
            draw_clear_alpha(0, 0);
            gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
            draw_surface_ext(_surf1, 0, 0, 1, 1, 0, _spr_col, _spr_alpha);
            gpu_set_blendmode(bm_normal);
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


/// @desc               Create a baked sprite with an string outlined.
/// @arg font           The font that will be used with the outline.
/// @arg string         The string to be writen.
/// @arg colour         The color of the string.
/// @arg alpha          The alpha of the string.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_bake_sprite_text(_font, _string, _str_col, _str_alpha, _ol_config = ol_config()) {
    var _thick  = _ol_config.line_width;
    var _col    = _ol_config.line_col;
    var _alpha  = _ol_config.line_alpha;
    var _round  = _ol_config.roundness;
    var _tol    = _ol_config.tolerance;
    var _res    = _ol_config.resolution;
    var _uv_bnd = _ol_config.uv_bound_mode;
    
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
        case fa_center: {_xx = _str_w*0.5}    break;
        case fa_right:  {_xx = _str_w}        break;
    }
    switch (_valign) {
        case fa_middle: {_yy = _str_h*0.5}    break;
        case fa_bottom: {_yy = _str_h}        break;
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


/// @desc               Create a baked sprite with an string outlined with extra formating.
/// @arg font           The font that will be used with the outline.
/// @arg string         The string to be writen.
/// @arg sep            The distance in pixels between lines of text.
/// @arg w              The maximum withd in pixels of the string before a line break.
/// @arg colour         The color of the string.
/// @arg alpha          The alpha of the string.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_bake_sprite_text_ext(_font, _string, _sep, _w, _str_col, _str_alpha, _ol_config = ol_config()) {
    var _thick  = _ol_config.line_width;
    var _col    = _ol_config.line_col;
    var _alpha  = _ol_config.line_alpha;
    var _round  = _ol_config.roundness;
    var _tol    = _ol_config.tolerance;
    var _res    = _ol_config.resolution;
    var _uv_bnd = _ol_config.uv_bound_mode;
    
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
        case fa_center: {_xx = (_str_w/_lines)*0.5}    break;
        case fa_right:  {_xx = (_str_w/_lines)}        break;
    }
    switch (_valign) {
        case fa_middle: {_yy = ((_lines+_extra_lines)*_sep)*0.5}    break;
        case fa_bottom: {_yy = ((_lines+_extra_lines)*_sep)}        break;
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
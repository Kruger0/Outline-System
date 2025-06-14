

/// @desc               Set the outline shader for the next draw texts.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_set_text(_ol_config = ol_config()) {
    static uv_default = [0.0, 0.0, 1.0, 1.0];
    
    var _thick  = _ol_config.line_width;
    var _col    = _ol_config.line_col;
    var _alpha  = _ol_config.line_alpha;
    var _round  = _ol_config.roundness;
    var _tol    = _ol_config.tolerance;
    var _res    = _ol_config.resolution;
    var _uv_bnd = _ol_config.uv_bound_mode;
        
    var _font = draw_get_font();
    var _texture = font_get_texture(_font);
    var _uv = _uv_bnd ? font_get_uvs(_font) : uv_default;
    
    __outline_set_shader();
    __outline_set_uniforms(_texture, _uv, _thick, _col, _alpha, _tol, _res, _round, _uv);
}


/// @desc               Draw an outlined text.
/// @arg x              The X coordinate of the text.
/// @arg y              The Y coordinate of the text.
/// @arg string         The string to be drawed.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_text(_x, _y, _string, _ol_config = ol_config()) {
    var _col = draw_get_color();
    outline_draw_text_ext_transformed_color(_x, _y, _string, string_height("I"), -1, 1, 1, 0, _col, _col, _col, _col, draw_get_alpha(), _ol_config);
}


/// @desc               Draw an outlined text with extra formating.
/// @arg x              The X coordinate of the text.
/// @arg y              The Y coordinate of the text.
/// @arg string         The string to be drawed.
/// @arg sep            The distance in pixels between lines of text.
/// @arg w              The maximum withd in pixels of the string before a line break.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_text_ext(_x, _y, _string, _sep, _w, _ol_config = ol_config()) {
    var _col = draw_get_color();
    outline_draw_text_ext_transformed_color(_x, _y, _string, _sep, _w, 1, 1, 0, _col, _col, _col, _col, draw_get_alpha(), _ol_config);
}


/// @desc               Draw an outlined text with color.
/// @arg x              The X coordinate of the text.
/// @arg y              The Y coordinate of the text.
/// @arg string         The string to be drawed.
/// @arg c1             The colour for the top left of the drawn text.
/// @arg c2             The colour for the top right of the drawn text.
/// @arg c3             The colour for the bottom left of the drawn text.
/// @arg c4             The colour for the bottom right of the drawn text.
/// @arg alpha          The alpha of the string.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_text_color(_x, _y, _string, _c1, _c2 = _c1, _c3 = _c1, _c4 = _c1, _a = 1, _ol_config = ol_config()) {
    outline_draw_text_ext_transformed_color(_x, _y, _string, string_height("I"), -1, 1, 1, 0, _c1, _c2, _c3, _c4, _a, _ol_config);
}


/// @desc               Draw an outlined text with transformations.
/// @arg x              The X coordinate of the text.
/// @arg y              The Y coordinate of the text.
/// @arg string         The string to be drawed.
/// @arg xscale         The horizontal scale of the string.
/// @arg yscale         The vertical scale of the string.
/// @arg angle          The angle of the string.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_text_transformed(_x, _y, _string, _xscale, _yscale, _ang, _ol_config = ol_config()) {
    var _col = draw_get_color();
    outline_draw_text_ext_transformed_color(_x, _y, _string, string_height("I"), -1, _xscale, _yscale, _ang, _col, _col, _col, _col, draw_get_alpha(), _ol_config);
}


/// @desc               Draw an outlined text with extra formating and color.
/// @arg x              The X coordinate of the text.
/// @arg y              The Y coordinate of the text.
/// @arg string         The string to be drawed.
/// @arg sep            The distance in pixels between lines of text.
/// @arg w              The maximum withd in pixels of the string before a line break.
/// @arg c1             The colour for the top left of the drawn text.
/// @arg c2             The colour for the top right of the drawn text.
/// @arg c3             The colour for the bottom left of the drawn text.
/// @arg c4             The colour for the bottom right of the drawn text.
/// @arg alpha          The alpha of the string.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_text_ext_color(_x, _y, _string, _sep, _w, _c1, _c2 = _c1, _c3 = _c1, _c4 = _c1, _a = 1, _ol_config = ol_config()) {
    outline_draw_text_ext_transformed_color(_x, _y, _string, _sep, _w, 1, 1, 0, _c1, _c2, _c3, _c4, _a, _ol_config);
}


/// @desc               Draw an outlined text with extra formating and transformations.
/// @arg x              The X coordinate of the text.
/// @arg y              The Y coordinate of the text.
/// @arg string         The string to be drawed.
/// @arg sep            The distance in pixels between lines of text.
/// @arg w              The maximum withd in pixels of the string before a line break.
/// @arg xscale         The horizontal scale of the string.
/// @arg yscale         The vertical scale of the string.
/// @arg angle          The angle of the string.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_text_ext_transformed(_x, _y, _string, _sep, _w, _xscale, _yscale, _ang, _ol_config = ol_config()) {
    var _col = draw_get_color();
    outline_draw_text_ext_transformed_color(_x, _y, _string, _sep, _w, _xscale, _yscale, _ang, _col, _col, _col, _col, draw_get_alpha(), _ol_config);
}


/// @desc               Draw an outlined text with transformations and color.
/// @arg x              The X coordinate of the text.
/// @arg y              The Y coordinate of the text.
/// @arg string         The string to be drawed.
/// @arg xscale         The horizontal scale of the string.
/// @arg yscale         The vertical scale of the string.
/// @arg angle          The angle of the string.
/// @arg c1             The colour for the top left of the drawn text.
/// @arg c2             The colour for the top right of the drawn text.
/// @arg c3             The colour for the bottom left of the drawn text.
/// @arg c4             The colour for the bottom right of the drawn text.
/// @arg alpha          The alpha of the string.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_text_transformed_color(_x, _y, _string, _xscale, _yscale, _ang, _c1, _c2 = _c1, _c3 = _c1, _c4 = _c1, _a = 1, _ol_config = ol_config()) {
    outline_draw_text_ext_transformed_color(_x, _y, _string, string_height("I"), -1, _xscale, _yscale, _ang, _c1, _c2, _c3, _c4, _a, _ol_config);
}


/// @desc               Draw an outlined text with extra formating, transformations a color.
/// @arg x              The X coordinate of the text.
/// @arg y              The Y coordinate of the text.
/// @arg string         The string to be drawed.
/// @arg sep            The distance in pixels between lines of text.
/// @arg w              The maximum withd in pixels of the string before a line break.
/// @arg xscale         The horizontal scale of the string.
/// @arg yscale         The vertical scale of the string.
/// @arg angle          The angle of the string.
/// @arg c1             The colour for the top left of the drawn text.
/// @arg c2             The colour for the top right of the drawn text.
/// @arg c3             The colour for the bottom left of the drawn text.
/// @arg c4             The colour for the bottom right of the drawn text.
/// @arg alpha          The alpha of the string.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_text_ext_transformed_color(_x, _y, _string, _sep, _w, _xscale, _yscale, _ang, _c1, _c2 = _c1, _c3 = _c1, _c4 = _c1, _a = 1, _ol_config = ol_config()) {
    var _halign     = draw_get_halign();
    var _valign     = draw_get_valign();
    var _gap        = max(_ol_config.line_width, 0);
    var _str_wid    = _gap * 2 + string_width_ext(_string, _sep, _w);
    var _str_hei    = _gap * 2 + string_height_ext(_string, _sep, _w);
    var _surf       = __outline_surface_get(_str_wid, _str_hei);
    var _xx         = 0;
    var _yy         = 0;
    var _tx         = _gap;
    var _ty         = _gap;

    switch (_halign) {
        case fa_center: {
            _xx = _str_wid * 0.5;
            _tx = _xx;
        } break;
        case fa_right:  {
            _xx = _str_wid;
            _tx = _xx - _gap;
        } break;
    }
    switch (_valign) {
        case fa_middle: {
            _yy = _str_hei * 0.5;
            _ty = _yy;
        } break;
        case fa_bottom: {
            _yy = _str_hei;
            _ty = _yy - _gap;
        } break;
    }
    
    surface_set_target(_surf);
        draw_clear_alpha(0, 0);
        draw_text_ext_color(_tx, _ty, _string, _sep, _w, _c1, _c2, _c3, _c4, _a);
    surface_reset_target();

    var _sx = _x - _tx * _xscale;
    var _sy = _y - _ty * _yscale;
    
    var _len = point_distance(_tx, _ty, 0, 0);
    var _dir = point_direction(_tx, _ty, 0, 0);
    var _ox = _x + dcos(_dir + _ang) * _len * _xscale;
    var _oy = _y - dsin(_dir + _ang) * _len * _yscale;
    
    outline_draw_surface_ext(_surf, _ox, _oy, _xscale, _yscale, _ang, c_white, 1.0, _ol_config);
}
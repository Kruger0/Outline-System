

/// @desc               Set the outline shader for the next draw sprite.
/// @arg sprite         The sprite to be draw.
/// @arg subimg         The subimg of the sprite to be used.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_set_sprite(_sprite, _subimg, _ol_config = ol_config()) {
    static uv_default = [0.0, 0.0, 1.0, 1.0];
    
    var _thick  = _ol_config.line_width;
    var _col    = _ol_config.line_col;
    var _alpha  = _ol_config.line_alpha;
    var _round  = _ol_config.roundness;
    var _tol    = _ol_config.tolerance;
    var _res    = _ol_config.resolution;
    var _uv_bnd = _ol_config.uv_bound_mode;
    var _tex    = sprite_get_texture(_sprite, _subimg);
    var _uv     = _uv_bnd ? sprite_get_uvs(_sprite, _subimg) : uv_default;
    
    __outline_set_shader();
    __outline_set_uniforms(_tex, _uv, _thick, _col, _alpha, _tol, _res, _round, _uv);
    
    return _sprite;
}


/// @desc               Draw an outlined sprite.
/// @arg sprite         The sprite to be draw.
/// @arg subimg         The subimg of the sprite to be used.
/// @arg x              The X coordinate of the sprite.
/// @arg y              The Y coordinate of the sprite.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_sprite(_sprite, _subimg, _x, _y, _ol_config = ol_config()) {
    outline_draw_sprite_ext(_sprite, _subimg, _x, _y, 1, 1, 0, c_white, draw_get_alpha(), _ol_config);
}


/// @desc               Draw an outlined sprite with extra formating.
/// @arg sprite         The sprite to be draw.
/// @arg subimg         The subimg of the sprite to be used.
/// @arg x              The X coordinate of the sprite.
/// @arg y              The Y coordinate of the sprite.
/// @arg xscale         The horizontal scaling of the sprite.
/// @arg yscale         The vertical scaling of the sprite.
/// @arg rot            The rotation of the sprite.
/// @arg colour         The color of the sprite.
/// @arg alpha          The alpha of the sprite.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_sprite_ext(_sprite, _subimg, _x, _y, _xscale, _yscale, _rot, _spr_col, _spr_alpha, _ol_config = ol_config()) {
    outline_set_sprite(_sprite, _subimg, _ol_config);
    draw_sprite_ext(_sprite, _subimg, _x, _y, _xscale, _yscale, _rot, _spr_col, _spr_alpha);
    outline_end();
}


function outline_draw_sprite_general() {
    
}


function outline_draw_sprite_part() {
    
}


function outline_draw_sprite_part_ext() {
    
}


function outline_draw_sprite_pos() {
    
}


function outline_draw_sprite_stretched() {
    
}


function outline_draw_sprite_stretched_ext() {
    
}


function outline_draw_sprite_tiled() {
    
}


function outline_draw_sprite_tiled_ext() {
    
}
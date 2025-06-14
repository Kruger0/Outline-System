

/// @desc               Set the outline shader for the next draw surface.
/// @arg id             The surface to be draw.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_set_surface(_id, _ol_config = ol_config()) {
    static uv_default = [0.0, 0.0, 1.0, 1.0];
    
    var _thick  = _ol_config.line_width;
    var _col    = _ol_config.line_col;
    var _alpha  = _ol_config.line_alpha;
    var _round  = _ol_config.roundness;
    var _tol    = _ol_config.tolerance;
    var _res    = _ol_config.resolution;
    var _uv_bnd = _ol_config.uv_bound_mode;
        
    var _tex    = surface_get_texture(_id);
    var _uv     = _uv_bnd ? texture_get_uvs(_tex) : uv_default;
    
    __outline_set_shader();
    __outline_set_uniforms(_tex, _uv, _thick, _col, _alpha, _tol, _res, _round, _uv_bnd);
    
    return _id;
}


/// @desc               Draw an outlined surface.
/// @arg id             The surface to be draw.
/// @arg x              The X coordinate of the surface.
/// @arg y              The Y coordinate of the surface.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_surface(_id, _x, _y, _ol_config = ol_config()) {
    outline_set_surface(_id, _ol_config);
    draw_surface(_id, _x, _y);
    outline_end();
}


/// @desc               Draw an outlined surface with extra formating.
/// @arg id             The surface to be draw.
/// @arg x              The X coordinate of the surface.
/// @arg y              The Y coordinate of the surface.
/// @arg xscale         The horizontal scaling of the surface.
/// @arg yscale         The vertical scaling of the surface.
/// @arg rot            The rotation of the surface.
/// @arg col            The color of the surface.
/// @arg alpha          The alpha of the surface.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_surface_ext(_id, _x, _y, _xscale, _yscale, _rot, _col, _alpha, _ol_config = ol_config()) {
    outline_set_surface(_id, _ol_config);
    draw_surface_ext(_id, _x, _y, _xscale, _yscale, _rot, _col, _alpha);
    outline_end();
}


/// @desc               Draw an outlined surface with general transformation parameters.
/// @arg id             The surface to be draw.
/// @arg left           The left edge of the source rectangle on the surface.
/// @arg top            The top edge of the source rectangle on the surface.
/// @arg width          The width of the source rectangle on the surface.
/// @arg height         The height of the source rectangle on the surface.
/// @arg x              The X coordinate to draw the surface at.
/// @arg y              The Y coordinate to draw the surface at.
/// @arg xscale         The horizontal scaling of the surface.
/// @arg yscale         The vertical scaling of the surface.
/// @arg rot            The rotation of the surface.
/// @arg c1             The colour for the top left of the surface.
/// @arg c2             The colour for the top right of the surface.
/// @arg c3             The colour for the bottom right of the surface.
/// @arg c4             The colour for the bottom left of the surface.
/// @arg alpha          The alpha of the surface.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_surface_general(_id, _left, _top, _width, _height, _x, _y, _xscale, _yscale, _rot, _c1, _c2, _c3, _c4, _surf_alpha, _ol_config = ol_config()) {
    outline_set_surface(_id, _ol_config);
    draw_surface_general(_id, _left, _top, _width, _height, _x, _y, _xscale, _yscale, _rot, _c1, _c2, _c3, _c4, _surf_alpha);
    outline_end();
}


/// @desc               Draw an outlined part of a surface.
/// @arg id             The surface to be draw.
/// @arg left           The left edge of the source rectangle on the surface.
/// @arg top            The top edge of the source rectangle on the surface.
/// @arg width          The width of the source rectangle on the surface.
/// @arg height         The height of the source rectangle on the surface.
/// @arg x              The X coordinate to draw the surface at.
/// @arg y              The Y coordinate to draw the surface at.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_surface_part(_id, _left, _top, _width, _height, _x, _y, _ol_config = ol_config()) {
    outline_set_surface(_id, _ol_config);
    draw_surface_part(_id, _left, _top, _width, _height, _x, _y);
    outline_end();
}


/// @desc               Draw an outlined part of a surface with extra formating.
/// @arg id             The surface to be draw.
/// @arg left           The left edge of the source rectangle on the surface.
/// @arg top            The top edge of the source rectangle on the surface.
/// @arg width          The width of the source rectangle on the surface.
/// @arg height         The height of the source rectangle on the surface.
/// @arg x              The X coordinate to draw the surface at.
/// @arg y              The Y coordinate to draw the surface at.
/// @arg xscale         The horizontal scaling of the surface.
/// @arg yscale         The vertical scaling of the surface.
/// @arg col            The color of the surface.
/// @arg alpha          The alpha of the surface.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_surface_part_ext(_id, _left, _top, _width, _height, _x, _y, _xscale, _yscale, _col, _alpha, _ol_config = ol_config()) {
    outline_set_surface(_id, _ol_config);
    draw_surface_part_ext(_id, _left, _top, _width, _height, _x, _y, _xscale, _yscale, _col, _alpha);
    outline_end();
}


/// @desc               Draw an outlined surface with stretched dimensions.
/// @arg id             The surface to be draw.
/// @arg x              The X coordinate of the surface.
/// @arg y              The Y coordinate of the surface.
/// @arg width          The width at which to draw the surface.
/// @arg height         The height at which to draw the surface.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_surface_stretched(_id, _x, _y, _wid, _hei, _ol_config = ol_config()) {
    outline_set_surface(_id, _ol_config);
    draw_surface_stretched(_id, _x, _y, _wid, _hei);
    outline_end();
}


/// @desc               Draw an outlined surface with stretched dimensions and extra formating.
/// @arg id             The surface to be draw.
/// @arg x              The X coordinate of the surface.
/// @arg y              The Y coordinate of the surface.
/// @arg width          The width at which to draw the surface.
/// @arg height         The height at which to draw the surface.
/// @arg col            The color of the surface.
/// @arg alpha          The alpha of the surface.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_surface_stretched_ext(_id, _x, _y, _wid, _hei, _col, _alpha, _ol_config = ol_config()) {
    outline_set_surface(_id, _ol_config);
    draw_surface_stretched_ext(_id, _x, _y, _wid, _hei, _col, _alpha);
    outline_end();
}


/// @desc               Draw an outlined surface tiled across the room.
/// @arg id             The surface to be draw.
/// @arg x              The X coordinate to start tiling from.
/// @arg y              The Y coordinate to start tiling from.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_surface_tiled(_id, _x, _y, _ol_config = ol_config()) {
    outline_set_surface(_id, _ol_config);
    draw_surface_tiled(_id, _x, _y);
    outline_end();
}


/// @desc               Draw an outlined surface tiled across the room with extra formating.
/// @arg id             The surface to be draw.
/// @arg x              The X coordinate to start tiling from.
/// @arg y              The Y coordinate to start tiling from.
/// @arg xscale         The horizontal scaling of the surface.
/// @arg yscale         The vertical scaling of the surface.
/// @arg col            The color of the surface.
/// @arg alpha          The alpha of the surface.
/// @arg [ol_config]    The configuration struct for the outline. Use ol_config() to generate it.
function outline_draw_surface_tiled_ext(_id, _x, _y, _xscale, _yscale, _col, _alpha, _ol_config = ol_config()) {
    outline_set_surface(_id, _ol_config);
    draw_surface_tiled_ext(_id, _x, _y, _xscale, _yscale, _col, _alpha);
    outline_end();
}

if !(surface_exists(surf)) {
    surf = surface_create(200, 200)
}

surface_set_target(surf)

    draw_clear_alpha(0, 0)
    draw_sprite(spr_flag, current_time/50, 100, 100)

surface_reset_target()

//outline_set_surface(surf, ol_config(4, c_black, 1, 0.75))
//draw_surface(surf, 200, 200)
//draw_surface_ext(surf, 0, 0, 3, 3, 0, c_white, 1)
//draw_surface_general(surf, 0, 0, 200, 200, 0, 0, 3, 3, 0, c_white, c_white, c_white, c_white, 1)
//draw_surface_part(surf, 0, 0, 120, 100, 0, 0)
//draw_surface_stretched(surf, 0, 0, 400, 100)
outline_draw_surface_ext(surf, 0, 0, 3, 3, 0, -1, 1, ol_config(3, c_black, 1, 0.5))
//outline_end()

//var _text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod\ntempor incididunt ut labore et dolore magna aliqua.\n\nUt enim ad minim veniam, quis nostrud exercitation ullamco laboris\nnisi ut aliquip ex ea commodo consequat.\nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum\ndolore eu fugiat nulla pariatur.\nExcepteur sint occaecat cupidatat non proident, sunt\nin culpa qui officia deserunt molglit anim id est laborum."
//var _x = 32
//var _y = 32
//var _sep = 12
//var _w = 400
//var _scl = 3
//////draw_circle(32, 32, 2, 0)
//draw_set_font(fnt_test)

////outline_draw_text_ext_transformed(32, 32, "Outline Test", 12, 300, 3, 3, 0, ol_config(2, c_black, 1, 0.5))
////outline_draw_text_ext_transformed_color(32, 96, _text, 12, 300, 3, 3, 0, c_red, , , , 1, ol_config(4, c_black, 1, 0.5))
//draw_set_valign(va)
//draw_set_halign(ha)
//var _ang = ang
//var _xx = room_width/2
//var _yy = room_height/2
//var _test = "The quick brown fox\njumps over the lazy dog :)";
//outline_draw_text_transformed_color(_xx, _yy, _test, _scl, _scl, _ang, c_yellow, , , , 1, ol_config(2, c_red, 1, 0.5))
//draw_text_transformed_color(_xx, _yy, _test, _scl, _scl, _ang, c_white, c_white, c_white, c_white, 1)
//draw_circle(_xx, _yy, 4, true)
//draw_set_valign(0)
//draw_set_halign(0)
////draw_text_transformed_color(32, 96, _text, 2, 2, 0, c_yellow, c_yellow, c_yellow, c_yellow, 1)

////outline_draw_text(_x, _y, _text);

////draw_text_color(_x, _y, _text, c_red, c_red, c_red, c_red, 1)
////draw_text_ext(_x, _y, _text, string_height("."), -1)


////outline_draw_text(_x, _y, _text)

////var _wid = string_width_ext(_text, _sep, _w)
////var _hei = string_height_ext(_text, _sep, _w)

////draw_text_ext_transformed(_x, _y, _text, _sep, _w, _scl, _scl, 0)
//////draw_text_transformed(_x, _y, _text, _scl, _scl, 0)


////var _x1 = _x
////var _y1 = _y
////var _x2 = _x1 + _wid * _scl
////var _y2 = _y1 + _hei * _scl
////draw_rectangle(_x1, _y1, _x2, _y2, true)

//draw_set_font(-1)
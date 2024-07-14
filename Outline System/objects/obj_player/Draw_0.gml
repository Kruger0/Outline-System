
var _col = make_color_hsv((current_time/10)mod 255, 192, 255)
var _scl = 1.3
outline_draw_sprite_ext(sprite_index, 0, x, y, _scl, _scl, 0, -1, 1, ol_config(4, _col, 1, 1, 0.9, 0.8, true))

//draw_self()
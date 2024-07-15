
var _col = make_color_hsv((current_time/10)mod 255, 192, 255)
var _scl = 1.3
outline_draw_sprite_ext(sprite_index, 0, x, y, _scl, _scl, 0, -1, 1, ol_config(4, _col, 1, 1, 0.9, 0.8, true))

var _n = 0
var _h = 16
var _d = 90
var _config = ol_config(2, c_blue, 1, 1)
draw_set_font(fnt_3)
outline_draw_text_color(x, y-_d + ++_n*_h, "I'm the player!!", c_red,,,,1,_config)
outline_draw_text(x, y-_d + ++_n*_h, "I'm the player!!", _config)
outline_draw_text_color(x, y-_d + ++_n*_h, "I'm the player!!", c_red,,,,,_config)
outline_draw_text_ext(x, y-_d + ++_n*_h, "I'm the player!!", 14, 600, _config)
outline_draw_text_ext_color(x, y-_d + ++_n*_h, "I'm the player!!", 14, 600, c_red,,,,,_config)
outline_draw_text_ext_transformed(x, y-_d + ++_n*_h, "I'm the player!!", 14, 600, 1, 1, 0, _config)
outline_draw_text_ext_transformed_color(x, y-_d + ++_n*_h, "I'm the player!!", 14, 600, 1, 1, 0, c_red,,,,,_config)
outline_draw_text_transformed(x, y-_d + ++_n*_h, "I'm the player!!", 1, 1, 0, _config)
outline_draw_text_transformed_color(x, y-_d + ++_n*_h, "I'm the player!!", 1, 1, 0, c_red,,,,,_config)
draw_set_font(-1)
//draw_self()
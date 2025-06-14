
// Surface drawing
if !(surface_exists(surf)) {
    surf = surface_create(camera_get_view_width(view_camera[0]), camera_get_view_height(view_camera[0]))
}

surface_set_target(surf)
    draw_clear_alpha(0,0)
    with (obj_ball) {
        dir+= 2*direc
        var _x = x+lengthdir_x(len, dir)
        var _y = y+lengthdir_y(len, dir)
        draw_sprite_ext(sprite_index, 0, _x, _y, image_xscale, image_yscale, 0, image_blend, 1)
    }
surface_reset_target()
outline_draw_surface(surf, 0, 0, ol_config(-12, c_black, , 1))

// Text drawing HD
draw_set_font(fnt_2)

    // Struct drawing
    member.draw()

    draw_set_valign(1)
    draw_set_halign(1)

        outline_draw_text_transformed_color(400, 260, "Where is the village?", 0.4, 0.4, 0, c_white, c_white, c_blue, c_blue, ((dsin(current_time/5)+1)/2), ol_config(8, c_black, , 1))

    draw_set_valign(0)
    draw_set_halign(0)

// Text drawing pixel
draw_set_font(fnt_1)
    outline_draw_text_transformed_color(20, 20, "Quest: find the lumberjack.", 3, 3, 0, c_red, c_red, c_yellow, c_yellow, 1, ol_config(2, c_white, (dsin((current_time/5))+1)/2))

    var _hour = string_replace_all(string_format(current_hour  , 2, 0), " ", "0")
    var _minu = string_replace_all(string_format(current_minute, 2, 0), " ", "0")
    var _seco = string_replace_all(string_format(current_second, 2, 0), " ", "0")
    var _time = "Time: " + _hour + ":" + _minu + ":" + _seco

    outline_draw_text_transformed_color(20, 70+(dsin(current_time/8)*10), _time, 3, 3, 0, c_white, c_white, c_white, c_white, 1, ol_config(2, c_black, 1, 0))

draw_set_font(-1)
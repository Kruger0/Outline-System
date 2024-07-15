
if (keyboard_check_pressed(vk_down)) {
	game_restart()
}

if (keyboard_check_pressed(vk_up)) {
	room_goto(room == rm_demo_1 ? rm_demo_2 : rm_demo_1)
}
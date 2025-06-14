
//ang = 0
//ha = 0
//va = 0
thick = 1
roundness = 0
//dbg_slider(ref_create(self, "ang"), -180, 180, "Angle", 5)
dbg_slider(ref_create(self, "thick"), -8, 8, "Thickness", 1)
dbg_slider(ref_create(self, "roundness"), 0, 2)
//dbg_slider(ref_create(self, "ha"), 0, 2, "H Align", 1)
//dbg_slider(ref_create(self, "va"), 0, 2, "V Align", 1)

surf = -1

//var _len = 50
//var _dir = 274
//var _t = 0

//_t = get_timer()
//repeat(1000000) {
//    var _l = lengthdir_x(_len, _dir)
//}
//show_debug_message($"Done {_l} in {(get_timer()-_t)/1000}ms")

//_t = get_timer()
//repeat(1000000) {
//    var _s = dcos(_dir) * _len
//}
//show_debug_message($"Done {_s} in {(get_timer()-_t)/1000}ms")

//game_end()
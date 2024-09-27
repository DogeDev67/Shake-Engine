extends Node

func _process(delta):
	if Input.is_action_just_pressed('toggle_fullscreen'):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if Input.is_action_just_pressed("screenshot"):
		screenshot()

func screenshot():
	var capture = get_viewport().get_texture().get_image()
	var _time = Time.get_datetime_string_from_system()
	var filename = "user://Screenshot-{0}.png".format({"0":_time}).replace(":", "-") #windows mag es nicht ohne replace
	filename[4] = ":" # user-// -> user://
	capture.save_png(filename)
	KillFeed.add_text_local("Successfully saved screenshot.")

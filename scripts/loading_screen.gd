extends Control

const MAIN_MENU = preload("res://scenes/main_menu.tscn")

func _physics_process(delta):
	ModLoader.load_files(true)
	await ModLoader.loading_mods_finished
	get_tree().change_scene_to_packed(MAIN_MENU)

extends Control

@onready var aniplayer = $AnimationPlayer
@onready var cam = $cam
@onready var level_selection = $way_points/level_selection

var cam_target_pos : Vector2

func _physics_process(delta):
	cam.position = lerp(cam.position, cam_target_pos, 0.05)

func _ready():
	aniplayer.play("text_pulse")


func _on_singleplayer_pressed():
	cam_target_pos = level_selection.position


func _on_multiplayer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tech_house.tscn")


func _on_settings_pressed() -> void:
	Settings.show_settings(Vector2i(600, 400))

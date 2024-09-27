extends Button

@export var map_scene : PackedScene
@export var map_name : String = "default"
@onready var label_map_name = $Panel/label_map_name

func _ready():
	label_map_name.text = map_name



func _on_pressed():
	get_tree().change_scene_to_packed(map_scene)

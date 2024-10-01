extends CanvasLayer

@onready var aniplayer: AnimationPlayer = $Control/AnimationPlayer
@onready var control: Control = $Control

#Audio settings
@export var audio_bus_name : String = "Master"
@onready var _bus := AudioServer.get_bus_index(audio_bus_name)
@onready var s_master_volume: HSlider = $Control/Panel/TabBar/Audio/s_master_volume



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	s_master_volume.value = db_to_linear(AudioServer.get_bus_volume_db(_bus))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("back"):
		if visible:
			if aniplayer.is_playing() == false:
				hide_settings()


func _on_s_master_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(_bus, linear_to_db(value))


func show_settings(pos : Vector2i):
	show()
	
	control.position = Vector2(pos)
	aniplayer.play("fade")
	
func hide_settings():
	aniplayer.play_backwards("fade")
	
	await  aniplayer.animation_finished
	hide()

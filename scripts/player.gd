extends CharacterBody3D

@onready var shotgun = $head/cam/Shotgun

@export var speed : float = 10.0
@export var normal_speed : float = 10.0
@export var bhop_speed : float =  12.5
@onready var l_speed: Label = $ui/ui/l_speed

@onready var head = $head
@onready var cam = $head/cam
@onready var body = $body
@onready var gun_ray = $head/cam/gun_ray
@onready var health_bar = $ui/ui/health_bar
@onready var aniplayer = $AnimationPlayer
@onready var ui = $ui
@onready var username = $username
@onready var crosshair = $head/cam/crosshair
@onready var flashlight = $head/flashlight
@onready var walking: AudioStreamPlayer3D = $walking
@onready var l_killstreak: Label = $ui/ui/l_killstreak
@onready var shotgun_cooldown: Timer = $shotgun_cooldown
@onready var shooting: AudioStreamPlayer3D = $shooting

@export var kill_streak : int = 0

var last_kill : String

var team : String

var head_bob_amplitude : float = 0.004
var origin_head_pos : Vector3
var origin_shotgun_pos : Vector3

var time : float = 0
var gravity : float = 0.15
var jump_force : float = 15

var mouse_sensitivity = 0.002 #0.0003456 

var attacked_by_id : int = 0

signal death_signal(id : int)

var step_correction = 15



@export var health : int = 100
var shotgun_max_distance : float # is set to gun_ray length

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	#set_multiplayer_authority(name.to_int())
	
	team = GameManager.current_team
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	origin_head_pos = head.position
	origin_shotgun_pos = shotgun.position
	health_bar.max_value = health
	username.text = GameManager.username
	
	shotgun_max_distance = gun_ray.target_position.z
	
	if team == "red":
		username.modulate = Color.RED
	elif team == "blue":
		username.modulate = Color.DODGER_BLUE
		
	health_bar.position.y = get_viewport().size.y - (health_bar.size.y * 1.5)
	floor_constant_speed = true
	

func _physics_process(delta):
	if get_parent().is_in_group("multiplayer_map"):
		if !is_multiplayer_authority():
			return
	

	cam.make_current()
	body.hide()
	ui.show()
	username.hide()
	
	var dirx = Input.get_axis("move_left", "move_right")
	var dirz = Input.get_axis("move_forward", "move_backward")
	
	var movement_dir = transform.basis * Vector3(dirx, 0, dirz)
	
	var target_speed_x : float = movement_dir.x * speed
	var target_speed_z : float = movement_dir.z * speed
	
	
	if movement_dir != Vector3.ZERO:
		head.position.y += sin(time) * head_bob_amplitude 
		head.position.x += cos(time) * head_bob_amplitude / 2
		#shotgun.position.y += sin(time) * head_bob_amplitude / 2
		#shotgun.position.x += cos(time) * head_bob_amplitude / 4
	else:
		head.position = lerp(head.position, origin_head_pos, 0.05)
		#shotgun.position += lerp(shotgun.position, origin_shotgun_pos, 0.05)
		
	velocity.x = lerp(velocity.x, target_speed_x, 0.05)
	velocity.z = lerp(velocity.z, target_speed_z, 0.05)
	

			
	if !is_on_floor():
		velocity.y -= gravity
		speed = bhop_speed
		walking.stop()

	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y += jump_force 
		
	if Input.is_action_pressed('shoot') and shotgun_cooldown.time_left == 0:
		var damage
		shooting.play()
		shotgun_cooldown.start()
		
		if  gun_ray.get_collider() != null:
			if gun_ray.get_collider().is_in_group('entity'):
				var distance_to_peer = global_position.distance_to(gun_ray.get_collider().global_position)
				damage = calculate_damage(75, distance_to_peer , shotgun_max_distance)
				gun_ray.get_collider().take_damage(damage)
				
			if get_parent().is_in_group("multiplayer_map"):
				if gun_ray.get_collider().is_in_group("player") and gun_ray.get_collider() != get_parent():
					var hit_peer_id = gun_ray.get_collider().name.to_int()
					var distance_to_peer = global_position.distance_to(get_parent().get_node(str(hit_peer_id)).global_position)
					damage = calculate_damage(75, distance_to_peer , shotgun_max_distance)
					print(str(damage))
				
					network_set_killer(hit_peer_id, name.to_int())
					network_set_killer.rpc(hit_peer_id, name.to_int())
					
					take_damage(hit_peer_id, damage)
					rpc("take_damage", hit_peer_id, damage)
		aniplayer.stop()
		aniplayer.play("shoot")
		
		
	if Input.is_action_just_pressed("photo_mode_toggle"):
		ui.visible = !ui.visible
		shotgun.visible = !shotgun.visible
		crosshair.visible = !crosshair.visible
		
		
	if Input.is_action_just_pressed("flashlight_toggle"):
		flashlight.visible = !flashlight.visible
		
		
		
		
	if target_speed_x == 0 and target_speed_z == 0:
		time = 0

	if velocity.y == 0:
		speed = normal_speed
		if velocity.floor() != Vector3.ZERO and walking.playing == false:
			walking.play()
		elif velocity.x > -step_correction and velocity.x < step_correction:
			if velocity.z > -step_correction and velocity.z < step_correction:
				walking.stop()

	move_and_slide()
	

	
	health_bar.value = health
	GameManager.player_transform = transform
	
	l_speed.text = "Velocity: " + str(Vector3i(velocity))
	l_killstreak.text = "Kill streak: " + str(kill_streak)
	
	#velocity_label.text = 'velocity: ' + str(velocity)
	time += 0.02

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, -1.2, 1.2)


@rpc("any_peer")
func death(id : int):
	if get_parent().get_node(str(id)):
		var peer = get_parent().get_node(str(id))
		var killer = get_parent().get_node(str(peer.attacked_by_id))
		peer.death_signal.emit(name.to_int())
		
		network_set_killstreak.rpc(killer.name.to_int(), killer.kill_streak + 1)
		network_set_killstreak.rpc(peer.name.to_int(), 0)
		
		KillFeed.add_kill_to_feed.rpc(killer.username.text, peer.username.text, killer.kill_streak)
		rpc("respawn", id)
		respawn(id)
		

@rpc("any_peer")
func respawn(id : int):
	if get_parent().get_node(str(id)):
		var peer = get_parent().get_node(str(id))
		if peer.team == "red":
			peer.global_position = GameManager.team_red.spawn_point
		elif peer.team == "blue":
			peer.global_position = GameManager.team_blue.spawn_point
		
		rpc("network_set_health", id, 120)
		network_set_health(id, 120)
		#TODO reset attacked_by_id


@rpc("any_peer")
func take_damage(id : int, damage : int):
	if get_parent().get_node(str(id)):
		get_parent().get_node(str(id)).health -= damage
		if get_parent().get_node(str(id)).health <= 0:
			rpc("death", id)
			#death(id)
			

@rpc("any_peer")
func network_set_health(id, value):
	if get_parent().get_node(str(id)):
		var peer = get_parent().get_node(str(id))
		peer.health = value

@rpc("any_peer")
func network_set_killstreak(id, value):
	if get_parent().get_node(str(id)):
		var peer = get_parent().get_node(str(id))
		peer.kill_streak = value

@rpc("any_peer")
func network_set_killer(id, value):
	var peer = get_parent().get_node(str(id))
	peer.attacked_by_id = value

func calculate_damage(x: float, d: float, m: float) -> float:
	# Ensure that damage doesn't go negative
	return sin(((m - d) / m) * (PI / 2)) * x # formel vom internet :P

extends CharacterBody3D
@export var health = 100
var player : CharacterBody3D
@onready var nav = $NavigationAgent3D

var speed : float = 9.0

func _ready():
	player = get_tree().get_nodes_in_group("player")[0]

func _physics_process(delta):
	nav.target_position = player.global_position
	
	velocity.x = (GameManager.player_transform.origin - transform.origin).normalized().x * speed
	velocity.z = (GameManager.player_transform.origin - transform.origin).normalized().z * speed
	if !is_on_floor():
		velocity.y -= 10
	
	look_at(GameManager.player_transform.origin)
	rotation.x = 0
	move_and_slide()


func take_damage(damage : float):
	health -= damage
	if health <= 0:
		queue_free()

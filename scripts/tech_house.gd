extends Node3D

@onready var ui = $ui
@onready var text_edit = $ui/ui/TextEdit
@onready var red = $spawn_points/red
@onready var blue = $spawn_points/blue
@onready var te_username = $ui/ui/te_username
@onready var team_selection: OptionButton = $ui/ui/OptionButton
@onready var ip: TextEdit = $ui/ui/ip

var addresse : String = "localhost"

var PORT : int = 5768
var peer = ENetMultiplayerPeer.new()
var server = UDPServer.new()
@export var player_scene: PackedScene
 
func _ready() -> void:
	peer.set_bind_ip(addresse)
	
	GameManager.create_teams()
	GameManager.team_blue.spawn_point = blue.global_position
	GameManager.team_red.spawn_point = red.global_position

func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.set_multiplayer_authority(id)
	player.name = str(id)
	call_deferred("add_child",player)
 

func _on_join_pressed():
	if team_selection.selected == -1:
		KillFeed.add_text_local("choose a [color=orange]TEAM[/color] before connecting.")
		return
	
	peer.create_client(addresse, PORT)
	
	multiplayer.multiplayer_peer = peer
	ui.hide()

func _on_host_pressed():
	if team_selection.selected == -1:
		KillFeed.add_text_local("choose a [color=orange]TEAM[/color] before connecting.")
		return
	
	peer.create_server(PORT)
	
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()
	ui.hide()


func _on_text_edit_text_changed():
	PORT = text_edit.text.to_int()


func _on_te_username_text_changed():
	GameManager.username = te_username.text


func _on_option_button_item_selected(index: int) -> void:
	if index == 0:
		GameManager.current_team = "blue"
	elif index == 1:
		GameManager.current_team = "red"


func _on_ip_text_changed() -> void:
	#peer.set_bind_ip(ip.text)
	pass

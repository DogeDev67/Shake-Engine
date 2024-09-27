extends CanvasLayer

@onready var killfeedwindow: RichTextLabel = $killfeedwindow

func _ready() -> void:
	killfeedwindow.scroll_following = true


@rpc("any_peer")
func add_kill_to_feed(player_1 : String, player_2 : String, kill_streak : int):
	var kill_message = "killed"
	
	killfeedwindow.text = killfeedwindow.text + player_1 + " [color=red]" + kill_message + "[/color] " + player_2 + "\n"
	
	if kill_streak == 5:
		killfeedwindow.text += player_1 + " is [color=orange]unstoppable[/color] \n"
	elif kill_streak == 10:
		killfeedwindow.text += player_1 + " is on a [color=purple]RAMPAGE[/color] \n"
	elif kill_streak == 20:
		killfeedwindow.text += player_1 + " is comitting [color=red]MASS-MURDER[/color] \n"


func add_text_local(value : String):
	killfeedwindow.text += value + "\n"

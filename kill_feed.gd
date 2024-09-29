extends CanvasLayer

@onready var killfeedwindow: RichTextLabel = $killfeedwindow

func _ready() -> void:
	killfeedwindow.scroll_following = true


@rpc("any_peer")
func add_kill_to_feed(player_1 : String, player_2 : String, kill_streak : int):
	var kill_message = "killed"
	
	killfeedwindow.text = killfeedwindow.text + player_1 + " [color=red]" + kill_message + "[/color] " + player_2 + "\n"
	
	
	# - 1, weil... die killstreak nachricht kommt erst 1 kill später aus irgendeinem grund
	if kill_streak == 5 - 1:
		killfeedwindow.text += player_1 + " is [color=orange]UNSTOPPABLE[/color] \n"
	elif kill_streak == 10 - 1:
		killfeedwindow.text += player_1 + " is on a [color=purple]RAMPAGE[/color] \n"
	elif kill_streak == 20 - 1:
		killfeedwindow.text += player_1 + " is comitting [color=red]MASS-MURDER[/color] \n"


func add_text_local(value : String):
	killfeedwindow.text += value + "\n"

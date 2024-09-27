extends Node

var team_red : team = team.new()
var team_blue : team = team.new()

var username : String = "Player"

var player_transform : Transform3D

var current_team : String


class team:
	var team_name : String
	var points : int = 0
	var spawn_point : Vector3


func create_teams():

	team_red.team_name = "red"
	team_blue.team_name = "blue"

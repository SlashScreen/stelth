extends Node2D

var won = false
export var id = 0
signal game_won

func win_game():
	won = true
	print("I won!!")
	emit_signal("game_won")

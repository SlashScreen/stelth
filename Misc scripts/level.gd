extends Node2D

var won = false
export var id = 0
export var timeToTake = 60
export var reconLevel = false
export var closingTime = 10
signal game_won

func win_game(): #NTS; win_game called from Entrance node
	won = true
	print("I won!!")
	emit_signal("game_won")

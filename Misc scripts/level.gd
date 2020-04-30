extends Node2D

var won = false
var playerWasSeen = false
export var id = 0
export var timeToTake = 60
export var reconLevel = false
export var closingTime = 10
export var nextScene : String
signal game_won

func win_game(): #NTS; win_game called from Entrance node
	won = true
	print("I won!!")
	emit_signal("game_won")

func calc_score(timer):
	var stars = 0
	if playerWasSeen == false:
		stars += 1
	if timer <= timeToTake:
		stars += 1
	#TODO: Think of a 3rd star thing
	return stars

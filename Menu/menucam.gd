extends Node2D

export var swingCurve: Curve
var next_angle = 0
var start_angle = 0
var next_pos : Vector2
var start_pos : Vector2
var iterator = 0
var difference
var speed = 2
var moving = false

func go_to(pos,angle): #Angle in Degrees
	set_position(pos)
	#set_rotation(angle)
	start_angle = get_rotation()
	next_angle = angle #set target angle
	difference = next_angle-start_angle
	#next_pos = pos
	moving = true

func _process(delta):
	#TODO: Rotation is linear, needs to be smooth
	if moving:
		iterator+=delta*speed
		var progress
		if difference == 0:
			start_angle = next_angle
			start_pos = next_pos
			progress = 1
			moving = false
		else:
			progress = iterator / difference
		
		if progress >= 1:
			moving = false
			pass
		
		set_rotation(start_angle+(difference*progress))

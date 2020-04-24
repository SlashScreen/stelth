extends Node2D

export var swingCurve: Curve
var next_angle = 0
var start_angle = 0
var next_pos : Vector2
var start_pos : Vector2
var iterator = 0
var moving = false

func go_to(pos,angle): #Angle in Degrees
	set_position(pos)
	set_rotation(angle)
	#next_angle = angle #set target angle
	#next_pos = pos
#	moving = true

#func _process(delta):
	#TODO: separate rotation and movement
	#if moving:
		#iterator+=1
		#var difference = next_angle-start_angle
		#var progress
		#if difference == 0:
		#	start_angle = next_angle
		#	start_pos = next_pos
		#	progress = 1
		#	moving = false
		#else:
		#	progress = iterator / difference
		
		#set_offset(start_pos+(start_pos.direction_to(next_pos).normalized()*swingCurve.interpolate(progress)))
		#set_rotation(start_angle-(difference*swingCurve.interpolate(progress)))

extends Node2D

export var rotCurve: Curve
var next_angle = 0
var start_angle = 0
var next_pos : Vector2
var start_pos : Vector2
var iterator = 0
var difference
var speed = 4
var progress = 0
var moving = false

func go_to(pos,angle): #Angle in Degrees
	set_position(pos)
	#set_rotation(angle)
	start_angle = get_rotation()
	next_angle = angle #set target angle
	difference = next_angle-start_angle
	progress = 0
	#next_pos = pos
	moving = true

func _process(delta):
	#TODO: Rotation is linear, needs to be smooth
	if moving:
		iterator+=delta*speed
		progress = (iterator / difference) 
		if progress >= 1:
			moving = false
			set_rotation(next_angle)
			pass
		else:
		#PROBLEM: It rubber bands back to start because offset is based on start position
		#I need to figure out where to put the interpolator
		#rotCurve.interpolate(progress)
			set_rotation(start_angle + ((difference * (progress)*rotCurve.interpolate(progress)) ) )#*rotCurve.interpolate(progress)))

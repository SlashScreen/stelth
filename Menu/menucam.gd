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
	set_position(pos) #The camera will follow this
	start_angle = get_rotation()
	next_angle = angle #set target angle
	difference = next_angle-start_angle
	progress = 0
	moving = true

func _process(delta):
	#TODO: Rotation is linear, needs to be smooth
	if moving:
		#Increase "iterator" - Iterator is in physical units
		iterator+=delta*speed
		#Catch divide by zero error
		if difference == 0:
			moving = false
			return
		#Calculate progress between start_andle and next_angle, 0-1
		progress = (iterator / difference) 
		#If it's finished, stop
		if progress >= 1:
			moving = false
			set_rotation(next_angle) #Ensure that it all lines up in the end
			return
		else: #else
			#Set rotation to the complex equation
			#Starting point + interpolated angle from start_angle to next_angle
			#by alpha "progress" by curve rotCurve 
			set_rotation(start_angle + ((difference * (progress)*rotCurve.interpolate(progress)) ) )

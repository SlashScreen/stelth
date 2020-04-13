extends Light2D

var next_angle = 0

func swing_to_direction(angle): #Angle in Degrees
	next_angle = angle #set target angle

func _process(delta):
	#TODO: Overhaul this to work with curves, somehow
	#Ideally,  this smooths the rotation of the flashlight by dividing the remaining distance between it and the target angle (nextangle) by 2, like that greek race thing. It doesn't work very well though
	set_rotation(get_rotation() + ( (next_angle - get_rotation()) / 2) )
	pass

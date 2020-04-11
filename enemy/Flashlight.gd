extends Light2D

var next_angle = 0

func swing_to_direction(angle): #Degrees
	next_angle = angle

func _process(delta):
	set_rotation(get_rotation() + ( (next_angle - get_rotation()) / 2) )
	pass

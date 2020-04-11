extends Light2D

var next_angle = 0

func swing_to_direction(angle): #Degrees
	next_angle = angle

func _process(delta):
	#gradually shift current rotation towards next angle
	pass

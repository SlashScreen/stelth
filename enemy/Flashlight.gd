extends Light2D

export var swingCurve: Curve
var next_angle = 0
var start_from = 0
var iterator = 0

func swing_to_direction(angle): #Angle in Degrees
	next_angle = angle #set target angle

func _process(delta):
	#TODO: Finish by getting start from reset loop
	iterator+=1
	var difference = next_angle-start_from
	var progress
	if difference == 0:
		start_from = next_angle
		progress = 1
	else:
		progress = iterator / difference
		
	set_rotation(start_from-(difference*swingCurve.interpolate(progress)))
	pass

extends Light2D

export var swingCurve: Curve
var next_angle = 0
var start_from = 0
var iterator = 0
var smoothness = 2

func swing_to_direction(angle): #Angle in Degrees
	next_angle = angle #set target angle

func _process(delta):
#	iterator+=1
#	var difference = next_angle-start_from
#	var progress
#	if difference == 0:
#		start_from = next_angle
#		progress = 1
#	else:
#		progress = iterator / difference
#
#	set_rotation(start_from-(difference*swingCurve.interpolate(progress)))
	#TAKE 2
	#TODO: Maybe make it work with the curve again.
	set_rotation(get_rotation() + diff_between_angles(get_rotation(),next_angle)/smoothness)

func diff_between_angles(A, B):
	#It took an entire day to solve this, basically
	#This just finds the absolute distance between 2 angles
	#I tried all sorts of math with angles and mod
	#But I just convert the angles into vectors, and find the angle between them.
	#BEcause games are held together with duct tape.
	var vA = Vector2(cos(A),sin(A))
	var vB = Vector2(cos(B),sin(B))
	return rad2deg(vA.angle_to(vB))/360.0
	

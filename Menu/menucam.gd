extends Node2D

export var rotCurve: Curve
var next_angle = 0
var start_angle = 0
var next_pos : Vector2
var start_pos : Vector2
var iterator = 0
var difference
var speed = 5
var progress = 0
var moving = false
var rotmargin = 500

func _ready():
	yield(get_tree().create_timer(1.0), "timeout") #Wait to pan down
	go_to(get_parent().get_node("Startmenu").get_position(),15) #Pan down

func go_to(pos,angle): #Angle in Degrees
	start_pos = get_position()
	next_pos = pos
	set_position(pos) #The camera will follow this
	start_angle = get_rotation()
	next_angle = angle #set target angle
	difference = next_angle-start_angle
	progress = 0
	moving = true

func _process(delta):
	#TODO: Perhaps stop during transit, and when the camera slows down, then rotate.
	if moving:
		#Increase "iterator" - Iterator is in physical units
		var campos = $menucam.get_camera_screen_center()
		#print(campos.distance_to(next_pos))
		if campos.distance_to(start_pos) < rotmargin or campos.distance_to(next_pos) < rotmargin:
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
			set_rotation(deg2rad(next_angle)) #Ensure that it all lines up in the end
			return
		else: #else
			#Set rotation to the complex equation
			#Starting point + interpolated angle from start_angle to next_angle
			#by alpha "progress" by curve rotCurve 
			set_rotation(deg2rad(start_angle + ((difference * (progress)*rotCurve.interpolate(progress)) ) ) )

extends Camera2D

onready var fromPosition = get_offset()
onready var targetPosition = get_offset()
export var curve: Curve
var moving = false
var fromRotation = 0
var targetRotation = 0
var alpha = 0.0
var posDifference
var speed = 10
var iterator = 0

func go_to(topos, torot):
	fromRotation = get_rotation()
	fromPosition = Vector2(get_offset())
	targetRotation = torot
	targetPosition = topos
	posDifference = topos.distance_to(get_offset())
	moving = true

func _process(delta):
	if moving:
		alpha = float(get_offset().distance_to(targetPosition))/float(fromPosition.distance_to(targetPosition))
		print("-")
		print(get_offset().distance_to(targetPosition))
		print(fromPosition.distance_to(targetPosition))
		print(get_offset())
		print(fromPosition)
		print(targetPosition)
		print(alpha)
		if alpha >= 1.0:
			moving = false
			pass
		set_offset(get_offset()+(get_offset().direction_to(targetPosition).normalized() * curve.interpolate(alpha) * speed))

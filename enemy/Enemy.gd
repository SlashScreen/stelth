extends RigidBody2D

onready var player = get_parent().get_node("player")
onready var target = get_position()
export var state = "IDLE"
export var last_seen = Vector2()
export var suspicion_level = 0
export var FOV = 90
export var alert = 0
const CURIOUS_TIMER_MAX = 5
const SEARCHING_TIMER = 15
const SNAP_DIST = 10
const SPEED = 40
var sightDistance = 1000
var angle = 0
var seenTimer = 0
var searchTimer = SEARCHING_TIMER
var go = Vector2()
var path

func _process(delta):
	$Cast.set_cast_to(to_local(player.get_position()))
	
	#BEHAVIOR SWITCH
	
	#behavior that doesn't involve player detection
	match state:
		"IDLE":
			angle = rad2deg(Vector2().angle_to_point(go))
		"CURIOUS","FOUND":
			if is_at_target():
				angle += 1
			else:
				angle = rad2deg(get_position().angle_to_point(target))
	#behavior that *does* involve player detection
	if canSeePlayer():
		match state:
			"IDLE":
				#TODO: Reimplement flashlight distance
				state = "CURIOUS"
			"CURIOUS":
				if searchTimer <= CURIOUS_TIMER_MAX:
					searchTimer += delta
				else:
					state = "FOUND"
				target = player.get_position()
			"FOUND":
				seenTimer = SEARCHING_TIMER
				target = player.get_position()
	else:
		match state:
			"CURIOUS":
				if searchTimer > 0:
					searchTimer -= delta
				else:
					state = "IDLE"
			"FOUND":
				if seenTimer > 0:
					seenTimer -= delta
				else:
					state = "CURIOUS"
	
	#print(state)
	#MOVEMENT LOOP
	path = get_parent().get_node("Nav").get_simple_path(get_position(),target)
	if get_position().distance_to(path[1]) > SNAP_DIST:
		go = get_position().direction_to(path[1]).normalized()
	else:
		go = Vector2()
	
	
	$Flashlight.swing_to_direction(deg2rad(angle))#set_rotation(deg2rad(angle))
	#print(angle)
	print(state)
	apply_central_impulse(go*SPEED)

func canSeePlayer():
	$Cast.set_cast_to(to_local(player.get_position()))
	
	var workingAngle = rad2deg(Vector2().angle_to_point(to_local(player.get_position())))
	
	return $Cast.get_collider() == player and ((angle-(FOV/2)) < (workingAngle) and (workingAngle) < (angle+(FOV/2))) and (get_position().distance_to(player.get_position()) <= sightDistance)

func registerNoise(pathlength, volume, position):
	#Volume is how far away the guard needs to be to have heard it
	print("Heard noise at " + str(position) + " " + str(pathlength) + " units away")
	if pathlength <= volume:
		state = "CURIOUS"
		target = position

func is_at_target():
	return get_position().distance_to(target) < SNAP_DIST

extends RigidBody2D

onready var player = get_parent().get_node("player")
onready var target = get_position()
export var state = "IDLE"
export var last_seen = Vector2()
export var suspicion_level = 0
export var FOV = 90
const CURIOUS_TIMER_MAX = 5
const SEARCHING_TIMER = 15
const SNAP_DIST = 40
const SPEED = 40
var sightDistance = 300
var angle = 0
var seenTimer = 0
var searchTimer = SEARCHING_TIMER
var go = Vector2()
var path

func _process(delta):
	$Cast.set_cast_to(to_local(player.get_position()))
	
	#BEHAVIOR SWITCH
	
	if canSeePlayer():
		if state == "IDLE":
			#If guard sees player, become CURIOUS
			print("found- curious")
			state = "CURIOUS"
			target = player.get_position()
		if state == "CURIOUS":
			#If state is CURIOUS and still can see player
			target = player.get_position() #set last seen position
			if seenTimer < CURIOUS_TIMER_MAX: #count up timer if less than max
				seenTimer += delta
			else: #if is max, guard has found player
				#TODO: Alert other guards
				seenTimer = 0
				state = "FOUND"
		if state == "FOUND":
			#If state found and guard can see player
			#Set target position and reset timer
			target = player.get_position()
			searchTimer = SEARCHING_TIMER
	else: 
		#If guard cannot see player directly
		if state == "CURIOUS":
			#If state is curious
			if seenTimer >= 0: #Count down timer is > 0
				seenTimer -= delta
			else: #otherwise
				seenTimer = 0 #reset timer
				state = "IDLE" #lost player 
				target = get_position()
				suspicion_level += 1 #raise alert level
		if state == "FOUND": #if found player but not in sight
			state = "CURIOUS" #curious
			#TODO: connenct to other guards
	
	print(state)
	#MOVEMENT LOOP
	path = get_parent().get_node("Nav").get_simple_path(get_position(),target)
	if get_position().distance_to(path[1]) > SNAP_DIST:
		go = get_position().direction_to(path[1]).normalized()

	apply_central_impulse(go*SPEED)
	

func canSeePlayer():
	$Cast.set_cast_to(to_local(player.get_position()))
	
	var workingAngle = (Vector2().angle_to_point(to_local(player.get_position())))*(180/PI)
	
	return $Cast.get_collider() == player and ((angle-(FOV/2)) < (workingAngle) and (workingAngle) < (angle+(FOV/2))) and (get_position().distance_to(player.get_position()) <= sightDistance)

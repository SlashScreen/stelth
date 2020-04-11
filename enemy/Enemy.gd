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
	
	if canSeePlayer():
		if state == "IDLE":
			var ppos = player.get_position()
			var dist = to_global(get_position()).distance_to(to_global(ppos))
			if (dist/sightDistance) <= (1.0/3.0):
				print("Immediate find")
				state = "FOUND"
				target = ppos
			elif (dist/sightDistance) <= (2.0/3.0):
				print("Investigate")
				state = "CURIOUS"
				target = ppos
			elif (dist/sightDistance) > (2.0/3.0):
				#TODO: add "huh?"
				print("Huh?...")
				angle = get_position().angle_to_point(ppos) * (180/PI)
		if state == "CURIOUS":
			#If state is CURIOUS and still can see player
			target = player.get_position() #set last seen position
			if seenTimer < CURIOUS_TIMER_MAX: #count up timer if less than max
				seenTimer += delta
			else: #if is max, guard has found player
				#TODO: Alert other guards
				print("Found player")
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
			if seenTimer >= 0:# and get_position().distance_to(target) < SNAP_DIST: #Count down timer is > 0
				seenTimer -= delta
			else: #otherwise
				print("lost player, now idle")
				alert+=1
				seenTimer = 0 #reset timer
				state = "IDLE" #lost player 
				target = get_position()
				suspicion_level += 1 #raise alert level
		if state == "FOUND": #if found player but not in sight
			print("Lost sight, mode to curious")
			state = "CURIOUS" #curious
			#TODO: connenct to other guards
	
	#print(state)
	#MOVEMENT LOOP
	path = get_parent().get_node("Nav").get_simple_path(get_position(),target)
	if get_position().distance_to(path[1]) > SNAP_DIST:
		go = get_position().direction_to(path[1]).normalized()
	else:
		go = Vector2()
	
	angle = rad2deg(Vector2().angle_to_point(go))
	$Flashlight.swing_to_direction(deg2rad(angle))#set_rotation(deg2rad(angle))
	#print(angle)

	apply_central_impulse(go*SPEED)

func canSeePlayer():
	$Cast.set_cast_to(to_local(player.get_position()))
	
	var workingAngle = (Vector2().angle_to_point(to_local(player.get_position())))*(180/PI)
	
	return $Cast.get_collider() == player and ((angle-(FOV/2)) < (workingAngle) and (workingAngle) < (angle+(FOV/2))) and (get_position().distance_to(player.get_position()) <= sightDistance)

func registerNoise(pathlength, volume, position):
	#Volume is how far away the guard needs to be to have heard it
	print("Heard noise at " + str(position) + " " + str(pathlength) + " units away")
	if pathlength <= volume:
		state = "CURIOUS"
		target = position

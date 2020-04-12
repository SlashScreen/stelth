extends RigidBody2D

onready var player = get_parent().get_node("player")
onready var target = get_position()
export var state = "IDLE"
export var last_seen = Vector2()
export var suspicion_level = 0
export var FOV = 90
export var alert = 0
export var flashlightSwingCurve: Curve
const CURIOUS_TIMER_MAX = 7
const SEARCHING_TIMER = 15
const HUH_MAX = 5
const SNAP_DIST = 10
const SPEED = 40
var sightDistance = 1000
var angle = 0
var seenTimer = 0
var searchTimer = SEARCHING_TIMER
var huhTimer = 0
var go = Vector2()
var flashlightInterp = 0
var flashlightSpeed = .25
var flashlightAmplitude = 2
var path

func _process(delta):
	$Cast.set_cast_to(to_local(player.get_position()))
	
	#BEHAVIOR SWITCH
	
	#behavior that doesn't involve player detection
	match state:
		"IDLE":
			#Point in the driection that the enemy is moving
			#TODO: add patrol path
			angle = rad2deg(Vector2().angle_to_point(go))
		"CURIOUS","FOUND":
			#If it is at the target, swing flashlight around in search of the player
			#If not, point towards target
			if is_at_target():
				#This controls the swinging animation by interpolating across a curve object
				flashlightInterp += delta*flashlightSpeed
				if flashlightInterp > 1:
					flashlightInterp = 0
				angle += flashlightSwingCurve.interpolate(flashlightInterp) * flashlightAmplitude
			else:
				angle = rad2deg(get_position().angle_to_point(target))
		"HUH":
			flashlightInterp += delta*flashlightSpeed
			if flashlightInterp > 1:
				flashlightInterp = 0
			angle += flashlightSwingCurve.interpolate(flashlightInterp) * flashlightAmplitude
			if huhTimer <= HUH_MAX:
				huhTimer += delta
			else:
				huhTimer = 0
				state = "IDLE"
	#behavior that *does* involve player detection
	if canSeePlayer():
		var ppos = player.get_position()
		var distance = get_position().distance_to(ppos)
		print(str(distance/sightDistance) + " " + state + " " + str(alert))
		match state:
			"IDLE":
				#If the guard sees the player, go into curious mode
				#If the player is right in front of the guard, then the player is found immediately
				if distance/sightDistance > (2.0/3.0):
					state = "HUH"
					angle = rad2deg(get_position().angle_to_point(ppos))
					huhTimer = 0
				elif distance/sightDistance <= (2.0/3.0) and distance/sightDistance >= (1.0/3.0):
					state = "CURIOUS"
					searchTimer = 0
				elif distance/sightDistance < (1.0/3.0):
					state = "FOUND"
			"HUH":
				#HUH means the guard is looking at where they Think they saw the player
				print(distance/sightDistance)
				if distance/sightDistance <= (2.0/3.0) and distance/sightDistance >= (1.0/3.0):
					state = "CURIOUS"
					searchTimer = 0
				elif distance/sightDistance < (1.0/3.0):
					state = "FOUND"
			"CURIOUS":
				#If sees player, move toward player and count up timer
				#If timer at max, then the guard has found the player.
				#Alert level affects time window player has to avoid detection- higher alert level means guards are more wary
				if searchTimer <= CURIOUS_TIMER_MAX - alert:
					searchTimer += delta
				else:
					state = "FOUND"
				target = ppos
			"FOUND":
				#If sees player and found, reset timer used for losing the player
				#And also track player
				
				#TODO: Communicate with other guards
				seenTimer = SEARCHING_TIMER
				target = ppos
	else: #If does not see player
		match state:
			"CURIOUS":
				#If does not see player, count down the timer that was counting up before
				#If timer was at 0, then return back to idle
				
				#TODO: Set alert level based on how close the player was to discovery?
				if is_at_target() and searchTimer > 0:
					searchTimer -= delta
				else:
					state = "IDLE"
			"FOUND":
				#If does not see player, count down timer
				#If timer at 0, then revert to curious state, set alert level
				
				alert+=1
				
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

extends RigidBody2D
#This is a general guard that will be the primary enemy of the game.

#onready variables
onready var player = get_parent().get_node("player") #Reference to player
onready var target: Vector2 = get_position() #Where the guard is planning to go next.
onready var nextPoint : Vector2
#Public variables
export var state = "IDLE" #State machine. States are "IDLE","HUH","CURIOUS","FOUND"
export var last_seen = Vector2()
export var FOV = 90 #FOV of vision cone. Degrees.
export var alert = 0 #ALERT LEVEL: How wary guards are. Alert affects: whether guards will enter the "huh?" state, how long the player has before they are spotted.
export var flashlightSwingCurve: Curve #Flashlight motion curve
export var patrolPathRef: String
export var personality: String #Personality type: determines innate wariness of each guard, as well as
#the sprite, dialog, and animations used. the 3 types are "NORMAL", "LAZY", and "SCARDEYCAT".

#Constans
const CURIOUS_TIMER_MAX = 7
const SEARCHING_TIMER = 15
const HUH_MAX = 5
const SNAP_DIST = 15
const SPEED = 40
const PATROL_SPEED = 20
const TARGET_CHECK_TIMER_MAX = .1
#Internal variables
var targetCache: Vector2 #stores target
var targetCheckTimer = 0 #timer for recalculating path
var compatriots = [] #list of all fellow guards, looped for communication
var sightDistance = 1000
var patrolPath
var angle #direction the guard is looking in. Degrees.
var seenTimer = 0
var searchTimer = SEARCHING_TIMER
var huhTimer = 0
var go = Vector2() #direction to go in.
var direction = Vector2()
var flashlightInterp = 0
var flashlightSpeed = .25
var flashlightAmplitude = 2
var path #ASTAR path to follow.
var progress = 0 #Progress along patrol path
var starPathProgress = 0 #progress along navigated path

func _ready():
	$debugline.set_as_toplevel(true)
	reg_subtitle("test1",1)
	reg_subtitle("test2",5)
	
	#Set default alert level based on personality type
	match personality:
		"LAZY":
			alert = -1
		"NORMAL":
			alert = 0
		"SCAREDYCAT":
			alert = 1
	#Find fellow guards, add all except self to list
	for node in get_tree().get_root().get_node("level").get_children(): #Get all nodes
		if node.get_filename() == "res://enemy/Enemy.tscn" and node != self:
			compatriots.append(node)
	#Load node
	patrolPath = get_tree().get_root().get_node("level").get_node(patrolPathRef)
	patrolPath.register(name)
	target = patrolPath.get_current_point(name)
	#TODO: load sprites and stuff

func _process(delta):
	#ray switching
	if player.crouching:
		$Cast.set_collision_mask_bit(0,true)
	else:
		$Cast.set_collision_mask_bit(0,false)
	#BEHAVIOR SWITCH
	
	#BEHAVIOR BREAKDOWN:
	#If the player is visible, or other stimulus is applied, the
	#guard will investigate the stmulus. If the player stays too long
	#in the cone of vision, or is too close to the guard, the guard will
	#become aware of the player's presence, alert other guards, and persue
	#the player. If the player enters the cone of vision, or a faint noise is heard,
	#The guard will simply point the flashlight in the stimulus' genral direction
	#for a few seconds.
	#The guard normally sticks to a patrol path, but will stop or break the path if
	#any stimulus is applied. I do not plan to add more complex social behavior.
	
	#TODO:
	#Talk to other gaurds, just casually?
	#Attack, both tackle and tazer 
	#Make interact with items: if item is misplaced, alert level, return to position
	
	#behavior that doesn't involve player detection
	
	match state:
		"IDLE":
			#Point in the driection that the enemy is moving
			if get_position().distance_to(target) < SNAP_DIST+20: #NOTE TO SELF: This is to reevent the janky stop-and go behavior.
				patrolPath.increment_point(name)
				target = patrolPath.get_current_point(name)
				#print(name + " " + str(target))
				
			angle = rad2deg(Vector2().angle_to_point(direction))
		"CURIOUS","FOUND":
			#If it is at the target, swing flashlight around in search of the player
			#If not, point towards target
			if is_at_target():
				swingFlashlight(delta)
			else:
				angle = rad2deg(get_position().angle_to_point(target))
		"HUH":
			swingFlashlight(delta)
			if huhTimer <= HUH_MAX:
				huhTimer += delta
			else:
				huhTimer = 0
				state = "IDLE"
				target = patrolPath.get_current_point(name)
	#behavior that *does* involve player detection
	if canSeePlayer() and player.citizen == false and get_position().distance_to(player.get_position()) <= 1000:
		var ppos = player.get_position()
		var distance = get_position().distance_to(ppos)
		var distprop = distance/sightDistance
		#print(str(distprop) + " " + state + " " + str(alert))
		match state:
			"IDLE":
				#This changes behavior based on how far away the player is from the guard.
				#If they are greater than 2/3 of the sight distance away from the guard, enter the "HUH" state, UNLESS they are already wary.
				#Between 1/3 and 2/3 enters CURIOUS mode.
				#If < 1/3, the guard immediatley "finds" the player.
				if distprop > (2.0/3.0):
					if alert == 0:
						state = "HUH"
						angle = rad2deg(get_position().angle_to_point(ppos)) #Whete the guard "Thought I saw something"
						huhTimer = 0 #Reset HUH timer
					else:
						state = "CURIOUS"
						searchTimer = 0
				elif distprop <= (2.0/3.0) and distance/sightDistance >= (1.0/3.0):
					state = "CURIOUS"
					searchTimer = 0
				elif distprop < (1.0/3.0):
					state = "FOUND"
					#TODO: make dialog based on like, a json file or someting.
					reg_subtitle("There's someone here!",3)
					print("immediate find")
			"HUH":
				#HUH means the guard is looking at where they Think they saw the player
				#This is basically identical to the IDLE block, except that there is no "huh?" mode, for obvious reasons
				
				if distprop <= (2.0/3.0) and distance/sightDistance >= (1.0/3.0):
					state = "CURIOUS"
					searchTimer = 0
				elif distprop < (1.0/3.0):
					state = "FOUND"
					reg_subtitle("There's someone here!",3)
					print("immediate find-huh")
			"CURIOUS":
				#If sees player, move toward player and count up timer
				#If timer at max, then the guard has found the player.
				#Alert level affects time window player has to avoid detection- higher alert level means guards are more wary
				if distprop < (1.0/3.0):
					state = "FOUND"
					
					print("immediate find-huh")
					
				if searchTimer <= CURIOUS_TIMER_MAX - alert:
					searchTimer += delta
				else:
					state = "FOUND"
					reg_subtitle("There's someone here!",3)
				target = ppos
			"FOUND":
				#If sees player and found, reset timer used for losing the player
				#And also track player
				for g in compatriots:
					get_tree().get_root().get_node("level").playerWasSeen = true
					#print("alerting another guard")
					g.alert(ppos)
				seenTimer = SEARCHING_TIMER
				target = ppos
	elif not canSeePlayer(): #If does not see player
		match state:
			"CURIOUS":
				#If does not see player, count down the timer that was counting up before
				#If timer was at 0, then return back to idle
				
				#TODO: Set alert level based on how close the player was to discovery?
				if searchTimer > 0:
					if is_at_target(): 
						searchTimer -= delta
				else:
					state = "IDLE"
					target = patrolPath.get_current_point(name)
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
	
	#HOW DOES THIS WORK?
	#It calculates the path to the Target variable.
	#To follow the path, it uses the "go" variable.
	#go is basically the normalized direction to the next point on the path.
	#The rigidbody is then provided an impulse to move in "go" direction.
	
	#Calculate path to taget using the navigator node
	if targetCheckTimer < TARGET_CHECK_TIMER_MAX:
		targetCheckTimer += delta
	else:
		targetCheckTimer = 0
		if targetCache != target:
			genPath()
			targetCache = target
	#if the enemy is close enough to the next point (Close enough defined by SNAP_DIST),
	#don't bother moving.
	#But if not, calculate go. 
	if get_position().distance_to(nextPoint) > SNAP_DIST:
		go = get_position().direction_to(nextPoint).normalized()
	else:
		go = Vector2()
		if starPathProgress+1 <= path.size():
			starPathProgress += 1
			nextPoint = path[starPathProgress-1]
	
	if go != Vector2(0,0):
			direction = go.normalized()
	#tell the flashlight to do its smoothing thing.
	$Flashlight.swing_to_direction(deg2rad(angle))#set_rotation(deg2rad(angle))
	#impulse rigidbody.
	if state == "IDLE":
		apply_central_impulse(go*PATROL_SPEED)
	else:
		apply_central_impulse(go*SPEED)

func alert(pos):
	#alerts all guards to position
	#print("alerted by another guard")
	state = "FOUND"
	seenTimer = SEARCHING_TIMER
	target = pos

func canSeePlayer():
	#Determines whether or not the enemy can see the player.
	
	#HOW IT WORKS:
	#A raycast node goes from the enemy to the player.
	#This function then checks 3 things:
	#Is the player within sightDistance to the enemy?
	#Is the raycast hitting the player?
	#Is the raycast direction within the view cone (defined by variable "angle" and "FOV")
	#If all of these things are true, the player is visible.
	
	#Set cast
	$Cast.set_cast_to(to_local(player.get_position()))
	#Calculate the direction of the raycast node.
	var workingAngle = rad2deg(Vector2().angle_to_point(to_local(player.get_position())))
	#Check all 3 of those things mentioned above.
	return $Cast.get_collider() == player and ((angle-(FOV/2)) < (workingAngle) and (workingAngle) < (angle+(FOV/2))) and (get_position().distance_to(player.get_position()) <= sightDistance)

func registerNoise(pathlength, volume, position):
	#volume is how far away the guard needs to be to have heard it
	#pathlength is how far away the noise is
	#position is where the noise originated from
	print("Heard noise at " + str(position) + " " + str(pathlength) + " units away")
	if pathlength <= volume:
		state = "CURIOUS"
		target = position

func is_at_target():
	#Determines whether the enemy is on top of the target position.
	return get_position().distance_to(target) < SNAP_DIST

func swingFlashlight(delta):
	#This controls the swinging animation by interpolating across a curve object
	#Call stack NTS: This delta variable originates from _process(delta).
	flashlightInterp += delta*flashlightSpeed #increment lerp variable
	if flashlightInterp > 1: #if greater than 0, reset
		flashlightInterp = 0
	#increment angle based on curve interpolation
	angle += flashlightSwingCurve.interpolate(flashlightInterp) * flashlightAmplitude

func genPath():
	starPathProgress = 0
	if state == "IDLE":
		path = get_parent().get_node("Nav").get_simple_path(get_position(),target)
	else:
		path = get_parent().get_node("Nav").get_simple_path(get_position(),target, false)
	$debugline.set_points(path)
	nextPoint = path[starPathProgress]

func reg_subtitle(sub,dur):
	get_tree().get_root().get_node("/root/sceneManager").add_subtitle(sub,dur)

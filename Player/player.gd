extends RigidBody2D
#This is the player master script. Everything the player can do in both modes can be found here.

#pulic variables.
export var crouching = false
export var citizen = false #This determines whether the player is 
#walking around like a normal person during the recon scenes,
#or in sneaky stealth mode.

#Constants.
const WALKING_SPEED = 75
const SNEAKING_SPEED = 25
const ROLL_SPEED = 150
const ROLL_COOLDOWN = 2
const ROLL_DURATION = .3 #Time for the actual roll

#Internal variables.
var go = Vector2() #which way to jolt the rigidbody.
var hold = false #If holding an item. You cannot roll while holding an item.
var direction = Vector2() #Last direction of movement: used for roll.
var speed = WALKING_SPEED
var movable = true #is the character able to move at ALL - used to freeze for cutscenes or whatever
var can_control = true #can the player control it - used to take away control during rolls
var roll_timer = 0
var items = []
var rolling = false
var rollingInterpolator = 0
var rollCooldownTimer = 0
var canRoll = true

#PLAYER MOVESET:
#Roll
#Walk
#Pick up item
#Knock to attract guard (Not implemented)
#Sneak to avoid detection, at the cost of lower visibility

func _ready():
# warning-ignore:return_value_discarded
	get_tree().get_root().get_node("level").connect("game_won",self,"_on_game_won")
	for node in get_tree().get_root().get_node("level").get_children(): #Get all nodes
		if node.get_filename() == "res://item/item.tscn": #If memeber of item class
			items.append(node)

func _process(delta):
	#MOVEMENT
	#"Movable" controls whether the player can move at all
	#"Can control" only restricts input
	#"go" variable is exactly the same as the one in Enemy.gd.
	if movable:
		if can_control:
			#can_control is used to relinquish control from the player
			#for only a certain amount of time, defined by ROLL_TIMER_MAX.
			#The timer to return control to the player is automatically counted down. This isn't very flexible, but it does
			#the job.
			
			#Cardinal Movement
			if Input.is_action_pressed("up"):
				go.y = -1
			if Input.is_action_pressed("down"):
				go.y = 1
			if Input.is_action_pressed("left"):
				go.x = -1
			if Input.is_action_pressed("right"):
				go.x = 1
			#knock
			if Input.is_action_just_pressed("knock"):
				$Knock.play_noise()
			#Sneak
			#If sneak button is pressed, reduce speed and restrict visiom
			if Input.is_action_just_pressed("sneak") and not citizen:
				speed = SNEAKING_SPEED
				crouching = true
				#Restrict vision by zooming in cameraand doing the masking thing
				$Sightline.show()
				$Camera.zoom = Vector2(1,1)
			#If it is released, return to normal speed and return visibility
			if Input.is_action_just_released("sneak") and not citizen:
				speed = WALKING_SPEED
				crouching = false
				#return visibility by removing the masking thing and zooming out the camera
				$Sightline.hide()
				$Camera.zoom = Vector2(2,2)
			#Grab item and let go
			#If the collect button is pushed and within a grab collider on an item class,
			#pick up the item (done in the item script)
			#TODO: Allow for multiple items by looping through all nodes and whatnot
			if Input.is_action_just_pressed("collect") and not citizen:
				for i in items:
					if i.movable and i.in_range(self):
						if hold: #If holding, let it go
							get_parent().get_node("item").let_go()
							hold = false
						else: #If not holding, pick it up
							get_parent().get_node("item").hold()
							hold = true
		else:
			#count up time to return control to the player.
			roll_timer += delta
			if roll_timer >= ROLL_DURATION:
				roll_timer = 0
				can_control = true
				#start roll cooldown timer
				canRoll = false
				rollCooldownTimer = 0
				rolling = false
		
		#reset roll cooldown timer
		if not canRoll and rollCooldownTimer < ROLL_COOLDOWN:
			rollCooldownTimer += delta
		elif rollCooldownTimer >= ROLL_COOLDOWN:
			canRoll = true
		#Rolling and movement impulse
		
		
		#This section goes like this:
		#Normally, the player's rigidbody is applied an impulse in the direction defined by the variable "go".
		#However, if the "roll" button is pressed, it provides a period of uncontrollable speed controlled by roll_curve 
		#described above, plays the noise, and relinquishes control.
		#The roll's impulse is in the direction of variable "direction", which is the
		#player's last direction of movement.
		#you cannot roll while holding a painting, otherwise you would break it.
		#This creates a moment of tension where the player must sneak out of the level without
		#half of the toolset.
		
		#Set state to rolling
		#If:
		#Input roll pressed
		#Player can control
		#Player not holding anything
		#Player isn't in recon mode ("citizen")
		#Player is crouching
		#Player is able to roll
		if Input.is_action_just_pressed("roll") and can_control and not hold and not citizen and crouching and canRoll:
			$Rollnoise.play_noise() #play noise
			can_control = false #relinquish control (timer stars automatically)
			rolling = true
			rollingInterpolator = 0
		
		if rolling: #if rolling, apply foce based on curve
			var rollCurve : Curve = load("res://Player/roll_curve.tres")
			rollingInterpolator += delta/ROLL_DURATION
			apply_central_impulse(direction*ROLL_SPEED*rollCurve.interpolate(rollingInterpolator))
		else:
			#Do normal behavior.
			apply_central_impulse(go.normalized()*speed)
		
		#Set player direction of movement.
		#The direction is never (0,0), otherwise you'd have to start moving to roll,
		#which is unintuitive to the player.
		#so, if the "go" variable is not (0,0), we can deduce that this is the
		#player's direction of movement. We store that.
		if go != Vector2(0,0):
			direction = go.normalized()
		#reset go variable to default (0,0)- if you don't reset it, you won't be able to stop,
		#which I think both of us can agree is an important aspect of a stealth game.
		#actually, a stealth game where you can't stop like no-brakes valet, or maybe a movement-based like
		#crypt of the necro-dancer, could be interesting, if done correctly. But I digress.
		go = Vector2()

func _on_game_won():
	#on game won, relinquish all movement. 
	#This might tie into a cutscene system later.
	movable = false

func ko (method): #ko = knock out
	#method is a sting that will eventually determine what animation to play
	movable = false
	$Camera/HUD.now_dead()

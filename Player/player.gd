extends RigidBody2D

const WALKING_SPEED = 75
const SNEAKING_SPEED = 25
const ROLL_SPEED = 1500
const ROLL_TIMER_MAX = .8
var go = Vector2()
var hold = false
var direction = Vector2()
var speed = WALKING_SPEED
var movable = true #is the character able to move at ALL - used to freeze for cutscenes or whatever
var can_control = true #can the player control it - used to take away control during rolls
var roll_timer = 0

func _ready():
	get_tree().get_root().get_node("level").connect("game_won",self,"_on_game_won")

func _process(delta):
	#MOVEMENT
	if movable:
		if can_control:
			#Cardinal Movement
			if Input.is_action_pressed("up"):
				go.y = -1
			if Input.is_action_pressed("down"):
				go.y = 1
			if Input.is_action_pressed("left"):
				go.x = -1
			if Input.is_action_pressed("right"):
				go.x = 1
			#Sneak
			if Input.is_action_just_pressed("sneak"):
				speed = SNEAKING_SPEED
				$Sightline.show()
				$Camera.zoom = Vector2(1,1)
			if Input.is_action_just_released("sneak"):
				speed = WALKING_SPEED
				$Sightline.hide()
				$Camera.zoom = Vector2(2,2)
			#Grab item and let go
			if Input.is_action_just_pressed("collect") and get_parent().get_node("item").in_range(self):
				if hold: #If holding, let it go
					get_parent().get_node("item").let_go()
					hold = false
				else: #If not holding, pick it up
					get_parent().get_node("item").hold()
					hold = true
		else:
			#count up time to return control to the player
			roll_timer += delta
			if roll_timer >= ROLL_TIMER_MAX:
				roll_timer = 0
				can_control = true
		#Rolling and movement- Rolling overrides normal movement.
		#TODO: add movement cooldown after roll? 
		if Input.is_action_just_pressed("roll") and can_control and not hold:
			#perhaps change roll impulse to be a constant force for ROLL-TIMER_MAX seconds?
			apply_central_impulse(direction*ROLL_SPEED)
			$Rollnoise.play_noise()
			can_control = false
		else:
			apply_central_impulse(go.normalized()*speed)
		#Set previous direction: (where player pointing)
		if go != Vector2(0,0):
			direction = go.normalized()
		#reset go variable
		go = Vector2()

func _on_game_won():
	#on game won, relinquish movement
	movable = false

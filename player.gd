extends RigidBody2D

const WALKING_SPEED = 75
const SNEAKING_SPEED = 25
var go = Vector2()
var speed = WALKING_SPEED

func _process(delta):
	if Input.is_action_pressed("up"):
		go.y = -1
	if Input.is_action_pressed("down"):
		go.y = 1
	if Input.is_action_pressed("left"):
		go.x = -1
	if Input.is_action_pressed("right"):
		go.x = 1
	if Input.is_action_just_pressed("sneak"):
		speed = SNEAKING_SPEED
		$Sightline.show()
		$Camera.zoom = Vector2(1,1)
	if Input.is_action_just_released("sneak"):
		speed = WALKING_SPEED
		$Sightline.hide()
		$Camera.zoom = Vector2(2,2)
	apply_central_impulse(go.normalized()*speed)
	go = Vector2()

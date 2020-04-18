extends RigidBody2D

class_name Guest

onready var target: Vector2 = get_position()
onready var nav = get_tree().get_root().get_node("level").get_node("Nav")
export var spriteAtlas: Image
const SNAP_DIST = 10
const SPEED = 40
var chosenItem
var go = Vector2()
var pointTowards = Vector2()
var otherGuests = []
var items = []
var path
var interestTimer = 0
var pathProgress = 0

#TODO: Dialogue?

func _ready():
	#TODO: Init sprites
	#init path
	path = nav.get_simple_path(get_position(),target)
	#Find other nodes
	for node in get_tree().get_root().get_node("level").get_children(): #Get all nodes
		if node.get_filename() == "res://item/item.tscn": #If memeber of item class
			items.append(node)
		if node.get_filename() == "res://Guest/Guest.tscn": #If memeber of item class
			otherGuests.append(node)
	
	resetTimer()

func _process(delta):
	if interestTimer > 0:
		interestTimer -= delta
	else:
		resetTimer()
		chosenItem = items[randi()%(len(items))]
		target = chosenItem.get_position()
		pathProgress = 0
	
	#TODO: Not update path every frame.
	path = nav.get_simple_path(get_position(),target)
	if get_position().distance_to(path[1]) > SNAP_DIST:
		go = get_position().direction_to(path[1]).normalized()
	else:
		go = Vector2()
	
	apply_central_impulse(go*SPEED)
#Pseudocode
#Set timer to random timer
#When timer goes down, choose item with least amount of guests
#Then move to item.
#Look at chosen item
#reset timer

func resetTimer():
	interestTimer = 10 + randi()%11+1

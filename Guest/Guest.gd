extends RigidBody2D

class_name Guest

onready var target: Vector2 = get_position()
onready var nextPoint: Vector2 = Vector2()
onready var nav = get_tree().get_root().get_node("level").get_node("Nav")
export var spriteAtlas: Image
const SNAP_DIST = 10
const SPEED = 40
const INTEREST_OFFSET = 2
var chosenItem
var go = Vector2()
var pointTowards = Vector2()
var otherGuests = []
var items = []
var path
var interestTimer = 0
var pathProgress = 0

#OVERVIEW
#Ah, yes. My hyper-intelligent, resource-efficient group AI system.
#Like the ghosts in pac-man, or Boids, they only perform a small set of actions
#in order to appear intelligent to the untrained eye. 
#This set of actions is:
#-every 10 + (random number from 1 to 10 seconds) they will choose a random
#item object (a painting or statue in the context of the game), pathfind to it,
#and stare at it for another random amount of time, then repeat the cycle.
#And that's it, so far. I literally coded this today, so I'll see if there should
#be something more added.

#FUTURE PLANS:
#Have some guests talk to eachother
#maybe have dummy AI just walking to random points on the map that are offscreen
#Think like a cartoon. What do extras in a cartoon do?

func _ready():
	#TODO: Init sprites
	#init path
	path = nav.get_simple_path(get_position(),target,false)
	$debugline.set_as_toplevel(true)
	#Find other nodes
	for node in get_tree().get_root().get_node("level").get_children(): #Get all nodes
		if node.get_filename() == "res://item/item.tscn": #If memeber of item class
			items.append(node)
		if node.get_filename() == "res://Guest/Guest.tscn": #If memeber of item class
			otherGuests.append(node)
	
	resetTimer() #set first timer

func _process(delta):
	if interestTimer > 0: #if timer still going
		interestTimer -= delta #decrease
	else: #if timer is through
		resetTimer() #reset timer
		chosenItem = items[randi()%(len(items))] #choose random item
		target = chosenItem.get_position() #set target to the item's position.
		path = nav.get_simple_path(get_position(),target, false) #draw path
		pathProgress = 0
		nextPoint = path[pathProgress]
		$debugline.set_points(path)
	
	#The rest of the movement code is almost the exact same in Enemy.gd.
	if get_position().distance_to(nextPoint) > SNAP_DIST:
		go = get_position().direction_to(nextPoint).normalized()
	else:
		go = Vector2()
		if pathProgress+1 <= path.size():
			print("increment path " + str(name) + " " + str(pathProgress) + " " + str(path.size()))
			pathProgress += 1
			nextPoint = path[pathProgress-1]
	
	apply_central_impulse(go*SPEED)

func resetTimer():
	#sets the timer. Void.
	interestTimer = INTEREST_OFFSET + randi()%11+1

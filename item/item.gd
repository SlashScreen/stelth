extends Sprite

var held = false

func hold():
	#makes it "held" by the player
	held = true

func let_go():
	#Drops the item.
	held = false

func in_range(body):
	#Returns whether rigidbody "body" is touching node Grabrange.
	return get_node("Grabrange").overlaps_body(body)

func _process(delta):
	if held:
		set_position(get_parent().get_node("player").get_position())

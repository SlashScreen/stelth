extends Sprite

var held = false

func hold():
	held = true

func let_go():
	held = false

func in_range(body):
	return get_node("Grabrange").overlaps_body(body)

func _process(delta):
	if held:
		set_position(get_parent().get_node("player").get_position())

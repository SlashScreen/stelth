extends MeshInstance2D

var held = false

func hold():
	held = true

func let_go():
	held = false

func _process(delta):
	if held:
		set_position(get_parent().get_node("player").get_position())

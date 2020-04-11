extends AudioStreamPlayer2D

export var volume = 0
onready var nav = get_tree().get_root().get_node("level").get_node("Nav")

func play_noise():
	play()
	for node in get_tree().get_root().get_node("level").get_children():
		#print(node.get_filename())
		if node.get_filename() == "res://enemy/Enemy.tscn":
			print(node.name)
			var path = nav.get_simple_path(to_global(get_position()),node.get_position())
			node.registerNoise(calc_path_length(path),volume,to_global(get_position()))
			
		

func calc_path_length(path):
	var length = 0
	for i in len(path):
		if i == 0:
			pass
		length += path[i-1].distance_to(path[i])
	return length

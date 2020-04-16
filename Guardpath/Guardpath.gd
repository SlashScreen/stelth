extends Path2D

class_name Patrol_Path

func move_head_to(d):
	$Head.set_offset(d)

func get_pos():
	return $Head.get_global_position()

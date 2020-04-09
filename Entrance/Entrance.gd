extends Sprite

func in_range(body):
	return get_node("Collisionarea").overlaps_body(body)

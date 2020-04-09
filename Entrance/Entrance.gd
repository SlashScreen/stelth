extends Sprite

func in_range(body):
	return get_node("Collisionarea").overlaps_body(body)


func _on_Collisionarea_body_entered(body):
	var player = get_parent().get_node("player")
	if body == player and player.hold == true:
			get_parent().win_game()

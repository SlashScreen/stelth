extends Button

func _on_Options_pressed():
	get_parent().get_parent().get_node("menucam").go_to(Vector2(300,300),0)

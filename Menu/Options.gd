extends Button

func _on_Options_pressed():
	get_parent().get_parent().get_node("Camnode").go_to(Vector2(300,300),0)

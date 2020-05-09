extends Button

func _on_Start_pressed():
	get_parent().get_parent().get_node("Camnode").go_to(get_parent().get_parent().get_node("Levelselect").get_position(),15)

extends Button

func _on_Options_pressed():
	get_parent().get_parent().get_node("Camnode").go_to(get_parent().get_parent().get_node("Options").get_position(),0)

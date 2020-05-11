extends Node

signal addSub(sub,dur)

func change_scene(path):
	get_tree().change_scene(path)

func add_subtitle(sub,dur):
	emit_signal("addSub",sub,dur)

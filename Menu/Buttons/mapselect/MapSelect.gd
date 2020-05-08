extends TextureButton

export var mapToLoad : String

func _on_MapSelect_pressed():
	get_tree().change_scene(mapToLoad)

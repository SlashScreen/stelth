extends Control

onready var timer = 0
var won = false

func _ready():
	print(get_tree().get_root().get_child(0).name)
	get_tree().get_root().get_node("level").connect("game_won",self,"_on_game_won")

func _process(delta):
	if not won:
		timer += delta
		get_node("Timer").set_text(str(timer))

func _on_game_won():
	won = true

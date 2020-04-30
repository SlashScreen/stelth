extends CanvasLayer

onready var timer = 0
onready var recon = get_tree().get_root().get_node("level").reconLevel
onready var timeToClose = get_tree().get_root().get_node("level").closingTime
onready var nextScene = get_tree().get_root().get_node("level").nextScene
var won = false

func _ready():
	#Connect to signal "game_won", which is broadcsted by the level script
	get_tree().get_root().get_node("level").connect("game_won",self,"_on_game_won")

func _process(delta):
	if recon:
		if not won:
			timer += delta
			get_node("Timer").set_text(str(round(timer)))
			if timer >= timeToClose:
				get_tree().get_root().get_node("level").win_game()
	else:
		#This is the level timer at the top of the screen.
		#This will effect your Rating at the end of each level.
		if not won:
			timer += delta
			get_node("Timer").set_text(str(round(timer))) #TODO: figure out how to round to decimal places

func _on_game_won():
	#When the game is won, show the victory screens
	won = true
	$Darkscreen.show()
	$continuebutton.show()
	if recon:
		pass
	else:
		#TODO: multiply string by value how?
		var string = ""
		for i in range(get_tree().get_root().get_node("level").calc_score(timer)):
			string += "*"
		$Rating.set_text(string)
		$Wintext.show() #"win" being the actual word, not "window"

func _on_continue_pressed():
	var manager = get_node("/root/sceneManager")
	$Rating.set_text("")
	if recon:
		manager.change_scene(nextScene)
	else:
		manager.change_scene("res://Menu/menu.tscn")
		

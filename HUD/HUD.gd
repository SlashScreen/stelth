extends CanvasLayer

onready var timer = 0
onready var recon = get_tree().get_root().get_node("level").reconLevel
onready var timeToClose = get_tree().get_root().get_node("level").closingTime
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
	if recon:
		pass
	else:
		$Wintext.show() #"win" being the actual word, not "window"

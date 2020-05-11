extends CanvasLayer

onready var timer = 0
onready var recon = get_tree().get_root().get_node("level").reconLevel
onready var timeToClose = get_tree().get_root().get_node("level").closingTime
onready var nextScene = get_tree().get_root().get_node("level").nextScene
var won = false
var subtitles = {}
var recalc_cache = false

func _ready():
	#Connect to signal "game_won", which is broadcsted by the level script
	get_tree().get_root().get_node("level").connect("game_won",self,"_on_game_won")
	get_tree().get_root().get_node("/root/sceneManager").connect("addSub",self,"add_subtitle")

func _process(delta):
	#handle subtitles
	handle_subs(delta)
	#handle timers
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
		

func add_subtitle(string,duration):
	#duration is in seconds
	var time = OS.get_ticks_usec() #Create a unique ID
	subtitles[time] = {} #Init sub dict
	subtitles[time]["string"] = string
	subtitles[time]["dur"] = duration
	subtitles[time]["timer"] = 0
	recalc_cache = true #set recalculation flag

func handle_subs(delta):
	#This is the subtitling system. 
	#Erik, falls du diese Nachricht lesen, Halt die Klappe. Es ist nicht für dich. "Zu viel wörter" existiert nicht hier.
	#Egal falls du diese Kommente lesen- es ist nicht kompliziert, aber, nicht almand in mein Kopf sind.
	
	#HOW IT WORKS:
	#Each subtitle is a dictionary entry (could be a class, but whatever, it works).
	#Each entry has a sring, timer, and maximum duration.
	#Each entry's key is an ID number, defined by the OS' tick cycle when it reaches that process.
	#This is so every subtitle is unique, even if it has the same data.
	
	#For every frame in the process node, the following happens:
	#We loop through all current entry, and count up their timers. If the timer reaches the value defined by
	#that entry's maximum value, that subtitle is deleted, and the script is given the flag to re-render the text, explained later.
	#The "Subtitles" label retains its own text, so if nothing is happening, we don't need to recalculate it.
	#to recalculate, we set the "recalc_cache" flag to true. This will re-render the text, and send it to the label.
	
	#To render it, we get the text from all active subtitles, and then put them together in a long string with newlines
	#between each subtitle, and pass it to the label.
	
	for key in subtitles.keys():
		var sub = subtitles[key]
		#for each in subtitles
		sub["timer"] += delta #increment timer
		#if timer ran out
		if sub["timer"] >= sub["dur"]:
			recalc_cache = true #rerender and recache later in loop
			subtitles.erase(key)
	#If we need to recalculate the subtitles...
	if recalc_cache:
		recalc_cache = false
		#TODO: Add color?...
		var activesubs = [] #This is the text we need to display
		for k in subtitles.values(): #Adds all of the sub keys to the list to render
			activesubs.append(k["string"])
		#Rendering
		var out = "" #Define string
		for s in activesubs: #Loop through subs
			out += s + "\n" #Add to string with a newline at the end
		#set text
		$Subtitles.set_text(out)
		
			

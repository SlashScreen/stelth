extends Node

signal addSub(sub,dur)

var guardScript = {}

func _ready():
	setup_subtitles()

func change_scene(path):
	get_tree().change_scene(path)

func add_subtitle(sub,dur):
	emit_signal("addSub",sub,dur)

func setup_subtitles():
	#if I need more subtitle files, Ill make this into a loop or whatever
	var file = File.new()
	file.open("res://enemy/guardDialog.json", file.READ)
	var text = file.get_as_text()
	guardScript = JSON.parse(text).get_result()
	file.close()

func subtitle_engine(page, id):
	#page is which json file to read
	#current valid page values are:
	#"guard"
	#identifier is which line to return
	
	#returns the line as a string, and a time as a float in seconds
	
	#pseudocode
	#in dict page
	#get identifier
	#if radomized = true
	#get random from lines
	#else
	#get first in lines
	#calculate time by length
	var workingScript
	var rng = RandomNumberGenerator.new()
	match page: #hello hardcoding, my old friend
		"guard":
			workingScript = guardScript
	var out
	if workingScript[id]["randomized"]: #if randomized, return random entry from lines
		out = workingScript[id]["lines"][rng.randi_range(0 , len( workingScript[id]["lines"]) -1 )]
	else: #else, return first entry
		out = workingScript[id]["lines"][0]
	#figures out how long to hold the subtitle for by using word count / 100 words per minute * 3
	var holdTime = (out.length()/50.0)*3
	#return
	return [out, holdTime]

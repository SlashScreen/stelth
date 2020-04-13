extends AudioStreamPlayer2D
#This is the sound effect script. Noise doesn't mean random, it's just like, a sound.

export var volume = 0 #"volume" is how far away guards have to be to hear the sound.
#Get reference to navigational node
onready var nav = get_tree().get_root().get_node("level").get_node("Nav")

#HOW DOES THIS WORK:
#This is a very simple and semi-realistic-ish noise propogation script.
#What that means, is that instead of a sound being a circle that any guard can hear,
#It instead responds to the surroundings- being blocked by walls, mostly.

#How it does this is obviously not *exactly* how sound works in real life,
#because simulating wave bending, reflection, and all of that would be way
#over the level of this game.

#Instead, the noise *pathfinds* to all of the guards in the scene, using whatever
#Godot's implementation of ASTAR pathfinding is. This allows it to be blocked, 
#or go around, walls. Then, it finds how long the path is, and sends that,
#the coordinates of the sound's origin, and the volume variable to each guard,
#who handles the data itself, determining whether that warrants investigation.

#This is, I believe, a similar approach to how the game Thief: The Dark Project (1998) does its 
#sound propogation. Maybe I'm wrong on that. Either way, it isn't a unique idea, and I heard it
#first somewhere in a Gamemaker's Toolkit video. This is just my interperetation and implementation of the idea.

#TODO: Change collision stuff based on crouching or standing.


func play_noise():
	#plays the sound effect, and does the pathfinding thing.
	play() #play the actual sound effect.
	#Loop through every node, check if it is a guard, perform pathfinding, and send the data.
	for node in get_tree().get_root().get_node("level").get_children(): #Get all nodes
		if node.get_filename() == "res://enemy/Enemy.tscn": #If memeber of guard class
			#Do the ASTAR pathfinding
			var path = nav.get_simple_path(to_global(get_position()),node.get_position())
			#Send origin position, path length, and volume to the current guard.
			node.registerNoise(calc_path_length(path),volume,to_global(get_position()))
			
		

func calc_path_length(path):
	#Calculates the length of a path object, which is a PoolVector2Array.
	#It loops through every point, gets the distance from it to the last point,
	#And tacks that length onto the enf od the length variable, which is then returned.
	var length = 0
	for i in len(path):
		if i == 0: #If it's 0, do the next loop. 
			#This approach finds the length to the previous point,
			#And there is no index at -1.
			pass
		length += path[i-1].distance_to(path[i]) #Add length to previous point.
	return length

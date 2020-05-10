extends Path2D

class_name Patrol_Path

var patrolTracker = {}
var pnts 
#patrolTracker goes:
#Node Name : Current point
func _ready():
	get_curve().set_bake_interval(50)
	pnts = get_curve().get_baked_points()

func move_head_to(d):
	$Head.set_offset(d)

func get_pos():
	return $Head.get_global_position()

func register(n):
	pnts = get_curve().get_baked_points()
	patrolTracker[n] = 0

func increment_point(n):
	if patrolTracker[n] + 1 > len(pnts)-1:
		patrolTracker[n] = 0
	else:
		patrolTracker[n] += 1

func get_current_point(n):
	return pnts[patrolTracker[n]]

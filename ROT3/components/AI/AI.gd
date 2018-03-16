extends Node

var alive = true
var awake = false
var target = null






func setup():
	get_parent().ai = self
	get_parent().add_to_group("actors")



func wake_up( by_who ):
	self.awake = true
	self.target = by_who

func find_path( to_cell ):
	return RPG.map.find_path( get_parent().cell, to_cell )

func chase():
	if !target: return
	var path = find_path( target.cell )
	if path.size() == 0: return
	elif path.size() == 2:
		get_parent().fighter.attack(target)
	elif path.size() > 2: # The target is more than 1 cell away
		var step_cell = path[1]
		get_parent().fighter.step_or_attack( step_cell - get_parent().cell )
		prints( get_parent().thing_name, "moves to", step_cell )

func act(delta):
	if awake and alive:
		if target: chase()



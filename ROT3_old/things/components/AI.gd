extends Node


"""
AI COMPONENT (Requires a Fighter component on the same Thing)
AI can:
	go between awake/sleep states
	aquire a target Thing
	chase a target with pathfinding
	attack a target in melee range

"""



const MODE_STOP = 0		# Stand still and do not act
const MODE_WANDER = 1	# Wander or idle randomly
const MODE_ADVANCE = 2	# Move toward the target, but sometimes random
const MODE_CHASE = 3	# Move relentlessly toward the target
const MODE_CONFUSED = 4	# Move randomly, attack any fighter moved into

onready var Owner = get_parent()

var awake = false
var target = null

export(int,"STOP","WANDER","ADVANCE","CHASE") var default_mode = MODE_CHASE

var ai_mode = MODE_STOP

var old_ai_mode = MODE_CHASE			# AI mode to revert to when temp AI ends
var temp_ai_time = 0	# temporary AI counter, in seconds


func step( direction, attack_collider=true, avoid_walls=true, force_action=false):
	# direction: Vector2 relative direction of movement
	# attack_collider: this Thing attacks a collider that can be attacked
	# avoid_walls: dont count the step as an action if you step into a collider
	# force_action: emit the "acted" signal no matter what
	
	
	# Clamp direction vector so travel is only max 1 cell
	direction.x = clamp(direction.x, -1, 1)
	direction.y = clamp(direction.y, -1, 1)
	
	# Calculate new cell
	var new_cell = Owner.cell + direction
	var acted = true
	# Check for colliders at new cell
	var collider = Owner.map.get_collider( new_cell )
	if collider == Owner.map: # if the collider is a wall..
		if avoid_walls:
			acted = false # dont count this as an action
		else:
			RPG.messageboard.message( "%s walks into the wall with a thud!" % Owner.get_message_name() )
			
	elif collider != null and collider != self: # if collider can be attacked..
#		print( "%s punches the %s in the face!" % [Owner.Name, collider.Name] )
		if attack_collider:
			if "fighter" in Owner.components:
				Owner.components.fighter.attack( collider )
		elif not avoid_walls:
			RPG.messageboard.message( "%s stumbled right into %s, watch out!" ) % \
							[Owner.get_message_name(), collider.get_message_name()]
		else:
			acted = false # dont count this as an action
	else: # the cell is empty, so step there
		Owner.cell = new_cell

	# Emit the acted signal, if we really acted..
	if acted or force_action:
		Owner.emit_signal("acted",DATA.DEFAULT_ACTION_TIME)




func get_save_dict():
	return {
		"awake": self.awake,
		"target": self.target,
		}



func wake_up( by_who ):
	self.awake = true
	self.target = by_who
	self.ai_mode = MODE_CHASE


func confuse( length=60 ):
	self.old_ai_mode = self.ai_mode
	self.ai_mode = MODE_CONFUSED
	temp_ai_time = length
	RPG.messageboard.message("%s looks confused." % Owner.get_message_name() )


func act_chase():
	if self.target:
		var path = Owner.map.get_node("Pathfinder").find_path( Owner.cell, self.target.cell )
		if path:
			if path.size() > 1:
				var step_cell = path[1]
				Owner.components.fighter.step_or_attack( step_cell - Owner.cell, true )



func act_wander( attack_blockers=false ):
	# Assemble valid neighbor cells to move to
	var options = []
	for key in RPG.DIRECTIONS:
		var cell = Owner.cell + RPG.DIRECTIONS[key]
		var blocker = Owner.map.get_collider(cell)
		# Add if cell is free, or attack_blockers==true and blocker can be attacked
		if blocker == null or (attack_blockers and blocker.is_in_group("actors")):
			options.append(cell)
	# Idle on random chance or if no neighbors to move to
	if options.empty() or randi()%10 < 4:
		Owner.components.fighter.idle()
	# Else pick a random direction and move there
	else:
		var n = randi() % options.size()
		var dir = options[n]
		Owner.components.fighter.step_or_attack(dir)
		



func act( step=5 ):
	if Owner.components.fighter.HP <= 0:
		prints( Owner.get_message_name(), " is dead and cant act" )
		return
	
	if self.temp_ai_time > 0:
		self.temp_ai_time -= step
	elif self.ai_mode != self.old_ai_mode:
		self.temp_ai_time = 0
		self.ai_mode = self.old_ai_mode
		RPG.messageboard.message("%s returns to normal." % Owner.get_message_name() )
	

	if self.awake:
		match self.ai_mode:
			MODE_STOP:
				return
			MODE_WANDER:
				act_wander()
			MODE_CONFUSED:
				act_wander(true)
			MODE_ADVANCE:
				act_chase()
			MODE_CHASE:
				act_chase()
	




func _ready():
	if Owner: # Subscribe to Owner as an AI component
		Owner.components["AI"] = self
		Owner.add_to_group("actors")

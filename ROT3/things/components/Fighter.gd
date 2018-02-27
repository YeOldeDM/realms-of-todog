extends Node2D
"""
FIGHTER COMPONENT
Fighters can:
	move and detect collision
	attack, and be attacked, and track combat stats
	Track Hitpoints and death functions
"""
signal HP_changed( to )
signal maxHP_changed( to )

signal gets_hit( amt, from )
signal dies( from )

#onready var Owner = get_parent()
export(int) var xp_value = 1

export(int) var HP = 10 setget _set_HP
onready var maxHP = 10 setget _set_maxHP


export(int) var Level = 1
export(int, 1, 255) var Strength = 1
export(int, 1, 255) var Dexterity = 1
export(int, 1, 255) var Intelligence = 1

export(int) var base_min_damage = 0
export(int) var base_max_damage = 2

# if true, does not lose HP from take_damage()
export(bool) var invincible = false

onready var Owner = get_parent()

var Gear	# Set by FighterGear Component

func is_HP_full():
	return self.HP >= self.maxHP





func get_strength():
	var total = self.Strength
	return total

func get_dexterity():
	var total = self.Dexterity
	return total

func get_intelligence():
	var total = self.Intelligence
	return total







# Die, optionally from a source
func die( from=null ):
	emit_signal("dies", from )
	if Owner:
		# Special condition if Player dies
		if "player" in Owner.components:
			Owner.components.player.kill( from )
		else:
			RPG.messageboard.message( "The %s has died." % Owner.get_message_name() )
			Owner.kill()
			


func heal_damage( amt ):
	amt = min( amt, self.maxHP - self.HP )
	self.HP += amt
	RPG.messageboard.message_healing( Owner, amt )


# Take HP damage, optionally from a source
func take_damage( amt=0, from=null ):
	if invincible:
		# drop out if invincible
		RPG.messageboard.message("%s cannot be harmed" % Owner.get_message_name())
		return
	
	# Clamp incoming damage. More than zero, no more than our current HP
	amt = clamp( amt, 0, self.HP )
	
	# Adjust HP property
	self.HP -= amt
	
	# Emit a signal
	emit_signal( "gets_hit", amt, from )
	
	# Print an attack message
	var from_name = "A mysterious force" 
	if from !=null:
		from.get_message_name()
	var our_name = Owner.get_message_name()
	RPG.messageboard.message_attack( from_name, our_name, amt )
	
	# Check for death
	if self.HP <= 0 and !invincible:
		die( from )
	






func get_attack_bonus():
	var attack = self.get_dexterity() / 2
	var weapon = get_weapon()
	if weapon:
		attack += weapon.components.equipment.accuracy
	if Gear:
		if "accuracy" in Gear:
			attack += Gear.accuracy

	var L = 3 
	if Owner and Owner == RPG.player:
		L = 5
	attack += self.Level / L
	return attack

func get_weapon():
	if Gear:
		if 'slots' in Gear:
			if Gear.slots.weapon:
				return Gear.slots.weapon


func get_weapon_damage():
	var damage_roll = roll_base_damage()
	if Gear:
		if "min_damage" in Gear:
			damage_roll = Gear.roll_damage()
		elif 'slots' in Gear:
			if Gear.slots.weapon:
				damage_roll = Gear.slots.weapon.components.equipment.roll_damage()
	damage_roll += self.get_strength() / 2
	return damage_roll

func get_armor_class():
	var ac = 10 + self.get_dexterity() / 4
	if Gear:
		if "armor_class" in Gear:
			ac += Gear.armor_class
		elif 'slots' in Gear:
			for slot in Gear.slots:
				if Gear.slots[slot]:
					ac += Gear.slots[slot].components.equipment.armor_class
	return ac



func roll_base_damage():
	return round( rand_range( self.base_min_damage, self.base_max_damage ) )



# Attack a target Thing, if they have a Fighter component
# Does not emit an "acted" signal!
func attack( who ):
	var result = RPG.process_attack( Owner, who )

	if result.hits:
		if "fighter" in who.components:
			who.components.fighter.take_damage( result.damage, Owner )




# Spend an action standing still doing nothing
func idle():
#	print( "%s stands in place..." % Owner.Name )
	Owner.emit_signal("acted")


# Step one cell in a direction, or attack a valid target
# emits an "acted" signal if the action is valid
func step_or_attack( dir, force_action=false ):
	var acted = true
	# Clamp vector to 1 cell in any direction
	dir.x = clamp( dir.x, -1, 1 )
	dir.y = clamp( dir.y, -1, 1 )

	# Calculate new cell
	var new_cell = Owner.cell + dir
	
	# Check for colliders at new cell
	var collider = Owner.map.get_collider( new_cell )
	if collider == Owner.map: # if the collider is a wall..
#		print( "%s hits the wall with a thud!" % Owner.Name )
		acted = false # dont count this as an action
	elif collider != null and collider != self: # if collider can be attacked..
#		print( "%s punches the %s in the face!" % [Owner.Name, collider.Name] )
		attack( collider )

	else: # the cell is empty, so step there
		Owner.cell = new_cell
	# Emit the acted signal, or not..
	if acted or force_action:
		if Owner:
			Owner.emit_signal("acted")

# Get a damage state index based on
# percent HP left. Used for Fighter
# LifeBar node.
func get_damage_state():
	var diff = (self.HP*1.0) / (self.maxHP*1.0)
	if diff >= 1.0:		return 0	# Uninjured
	elif diff >= 0.9:	return 1	# Barely Scratched
	elif diff >= 0.75:	return 2	# Lightly Injured
	elif diff >= 0.5:	return 3	# Heavily Injured
	elif diff >= 0.25:	return 4	# Critically Injured
	elif diff >= 0.1:	return 5	# Nearly Dead
	else:				return 6	# Dead


func equip_item( thing ):
	assert Gear
	assert "equipment" in thing.components
	
	var slot = thing.components.equipment.equip_slot
	if Gear.slots[slot] != null:
		# This slot is taken by another item
		# Return the name of this item for messaging purpose
		return Gear.slots[slot].get_message_name()
	else:
		Gear.slots[slot] = thing
		thing.components.equipment.equipped = true
		Gear.update_paperdoll()
		return "OK"

func dequip_item( thing ):
	assert Gear
	assert "equipment" in thing.components
	
	var slot = thing.components.equipment.equip_slot
	if Gear.slots[slot] == thing:
		Gear.slots[slot] = null
		thing.components.equipment.equipped = false
		Gear.update_paperdoll()
		return OK


func _ready():
	self.maxHP = self.HP
	if Owner: # Subscribe to parent as a Fighter component
		Owner.components["fighter"]=self



func _enter_tree():
	if Owner:
		Owner.z_index = RPG.THING_LAYER_ENTITY

func _set_HP( what ):
	HP = what
	emit_signal("HP_changed", HP )
	# Update LifeBar sprite
	if self.HP and self.maxHP:
		$LifeBar.frame = get_damage_state()


func _set_maxHP( what ):
	maxHP = what
	emit_signal( "maxHP_changed", maxHP )
	# Update LifeBar sprite
	$LifeBar.frame = get_damage_state()













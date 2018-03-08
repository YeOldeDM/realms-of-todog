extends Node

const THING_LAYER_MISC = 0
const THING_LAYER_ITEMS = 1
const THING_LAYER_ENTITY = 2
const THING_LAYER_FX = 3

const TILE_FAMILY = {
		"floors":{
			"bog_green":[0, 1, 2, 3], 
			"cobble_blood":[4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], 
			"crystal_floor":[16, 17, 18, 19, 20, 21], 
			"dirt":[22, 23, 24], 
			"nerves":[25, 26, 27, 28, 29, 30, 31], 
			"sand_stone":[32, 33, 34, 35, 36, 37, 38, 39], 
			"vines":[40, 41, 42, 43, 44, 45, 46], 
			"grey_dirt":[47, 48, 49, 50, 51, 52, 53, 54], 
			"hive":[55, 56, 57, 58], 
			"ice":[59, 60, 61, 62], 
			"lair":[63, 64, 65, 66], 
			"lava":[67, 68, 69, 70],
			"marble":[71, 72, 73, 74, 75, 76], 
			"mesh":[77, 78, 79, 80], 
			"pebble_brown":[81, 82, 83, 84, 85, 86, 87, 88, 89], 
			"rect_gray":[90, 91, 92, 93], 
			"rough_red":[94, 95, 96, 97], 
			"sandstone_floor":[98, 99, 100, 101, 102, 103, 104, 105, 106, 107], 
			"snake":[108, 109, 110, 111], 
			"swamp":[112, 113, 114, 115], 
			"tomb":[116, 117, 118, 119], 
			"volcanic_floor":[120, 121, 122, 123, 124, 125, 126]
		}, 
		"walls":{
			"beehives":[127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140], 
			"brick_brown":[141, 142, 143, 144, 145, 146, 147, 148], 
			"brick_dark":[149, 150, 151, 152, 153, 154, 155], 
			"brick_gray":[156, 157, 158, 159], 
			"crystal_wall":[160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173], 
			"hive":[174, 175, 176, 177], 
			"lair":[178, 179, 180, 181], 
			"marble_wall":[182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193], 
			"pebble_red":[194, 195, 196, 197], 
			"relief":[198, 199, 200, 201], 
			"sandstone_wall":[202, 203, 204, 205, 206, 207, 208, 209, 210, 211], 
			"slime":[212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227], 
			"stone_black_marked":[228, 229, 230, 231, 232, 233, 234, 235, 236], 
			"stone_brick":[237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248], 
			"stone_dark":[249, 250, 251, 252], 
			"stone_gray":[253, 254, 255, 256], 
			"tomb":[257, 258, 259, 260], 
			"undead":[261, 262, 263, 264], 
			"vault":[265, 266, 267, 268], 
			"volcanic_wall":[269, 270, 271, 272, 273, 274, 275], 
			"flesh":[276, 277, 278, 279, 280, 281, 282], 
			"vines":[283, 284, 285, 286, 287, 288, 289], 
			"yellow_rock":[290, 291, 292, 293]
		}
	}

const THING_PATH = "res://things/db/"

const ABBREV = {
	"male":		"M",
	"female":	"F",
	
	"godot":	"Gd",
	
	"waitor":	"Wa",
	}

const DIRECTIONS = {
    "N":    Vector2(0,-1),
    "NE":   Vector2(1,-1),
    "E":    Vector2(1,0),
    "SE":   Vector2(1,1),
    "S":    Vector2(0,1),
    "SW":   Vector2(-1,1),
    "W":    Vector2(-1,0),
    "NW":   Vector2(-1,-1),
    }

var game
var player

var player_data = {
	"name":		"Vladimir",
	"sex":		"male",
	"race":		"godot",
	"job":	"waitor",
	"XP":	0,
	}

var messageboard


onready var database = preload("res://database/Database.tscn").instance()

func save_game():
	var file = File.new()
	var data = game.get_game_dict()
	var opened = file.open("res://SAVE.json", File.WRITE)
	if !opened==OK: 
		print("couldn't open!")
		return
	file.store_line( to_json( data ) )
	file.close()
	

var _SID = 0
func spawn( what ):
	var thing = database.get_thing( what )
	
	thing.SID = _SID
	_SID += 1
	
	return thing


func get_random_tile_family_pair():
	var choices = [
		["bog_green", "vines"],
		["cobble_blood", "brick_dark"],
		["marble", "marble_wall"],
		["sand_stone", "sandstone_wall"]
		]
	return choices[ randi() % choices.size() ]

func get_random_tile_index_by_family( type, family ):
	assert type in TILE_FAMILY
	assert family in TILE_FAMILY[type]
	var list = TILE_FAMILY[type][family]
	var n = randi() % list.size()
	return list[n]





# Get a random int between two ints
func roll( n, m ):
	return int( round( rand_range( n, m ) ) )



func process_attack( attacker, target ):
	# hit or miss this attack roll
	var hits = false
	# attacker's weapon damage roll
	var damage = attacker.components.fighter.get_weapon_damage()
	# attack die roll
	var attack_roll = roll(1,30)
	# attacker to-hit bonus
	var attack_bonus = attacker.components.fighter.get_attack_bonus()
	# target's AC
	var ac = target.components.fighter.get_armor_class()
	
	# attack hits if modified attack roll meets/beats target AC
	hits = attack_roll + attack_bonus >= ac
	# always hit on a natural 28+
	if attack_roll >= 28:
		hits = true
	# always miss on a natural 1
	if attack_roll <= 1:
		hits = false
	
	# Throw messages
	var hit_txt = ["MISS!","HIT!"][int(hits)]

	var roll_txt = ">> Attack roll for %s: 1d30+%s=%s(%s) vs AC%s .. %s" % [attacker.get_message_name(), str(attack_bonus), str(attack_roll+attack_bonus), str(attack_roll), str(ac), hit_txt]
	RPG.messageboard.message( roll_txt )
	# Return combat result in dictionary form
	return {
		"hits":	hits,
		"damage":	damage,
		}
	


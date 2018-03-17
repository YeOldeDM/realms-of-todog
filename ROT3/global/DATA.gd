extends Node

###	DATA SINGLETON	###
#	Stores all global/persistent game data


const VERSION = {
		"MAJOR":	0,
		"MINOR":	0,
		"BABY":		43
		}


enum RACE {
	HUMAN,
	ELF,
	DEEP_ELF,
	DWARF,
	DEEP_DWARF,
	HALFLING,
	KOBOLD,
	ORC,
	OGRE,
	TROLL,
	MINOTAUR,
	MUMMY,
	SPRIGGAN,
	VAMPIRE,
	MERFOLK,
	GODOT
	}




const DEFAULT_ACTION_TIME = 5.0	# Fallback delta value for an action


var _SID = 0
func make_thing( path ):
	if $Things.has_node( path ):
		var obj = $Things.get_node(path).duplicate()
		obj.database_path = path
		obj.SID = _SID
		_SID += 1
		return obj
extends Node

###	DATA SINGLETON	###
#	Stores all global/persistent game data


const VERSION = {
		"MAJOR":	0,
		"MINOR":	0,
		"BABY":		42
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



func make_thing( path ):
	if $Things.has_node( path ):
		return $Things.get_node(path).duplicate()
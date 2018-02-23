extends Node

func get_thing( path ):
	if has_node( path ):
		return get_node( path ).duplicate()


func get_random_monster():
	return $Monster.get_children()[ randi() % $Monster.get_children().size() ]


func get_random_body_armor():
	return $Equipment/Body.get_children()[ randi() % $Equipment/Body.get_children().size() ]

func get_random_shield():
	return $Equipment/Shield.get_children()[ randi() % $Equipment/Shield.get_children().size() ]

func get_random_weapon():
	return $Equipment/Weapon.get_children()[ randi() % $Equipment/Weapon.get_children().size() ]
extends Node

func build_family():
	var file = File.new()
	file.open("res://tilefams.dict", File.WRITE)
	var data = {
		"floors":{},
		"walls":{},
		}
	var current_family = null
	var current_list = [0]
	var pre = "floor_"
	for i in get_child_count():
		var name = get_child(i).get_name()
		var idx = int(name)
		
		if idx == 0:
			if current_family:
				print(pre,current_family)
				if pre == "floor_":
					data.floors[current_family] = current_list
				elif pre == "wall_":
					data.walls[current_family] = current_list
			if name.begins_with("wall_"):
				pre = "wall_"
			current_family = name.replace(pre,"").replace(str(idx),"")
			current_list = []
		current_list.append(i)
	file.store_line( to_json( data ) )
	file.close()

func _ready():
	build_family()



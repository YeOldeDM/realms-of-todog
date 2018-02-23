extends Node
tool

func generate_tiles():
	var wall_dir = "res://graphics/dun/wall/"
	var floor_dir = "res://graphics/dun/floor/"
	var dir = Directory.new()
	dir.open( floor_dir )
	var files = []
	dir.list_dir_begin(true,true)
	var file = dir.get_next()
	while file != "":
		if file.ends_with(".png"):
			files.append(floor_dir+file)
		file = dir.get_next()
	

	dir.change_dir( wall_dir )
	dir.list_dir_begin(true,true)
	file = dir.get_next()
	while file != "":
		if file.ends_with(".png"):
			files.append(wall_dir+file)
		file = dir.get_next()

	for file in files:

		var new_sprite = Sprite.new()
		var ns = file.split("/")
		var name = ns[4]+"_"+ns[-1].replace(".png","")
		print(name)
		new_sprite.set_name( name )
		add_child(new_sprite)
		new_sprite.set_owner(self)
		new_sprite.texture = load( file )
		

func _ready():
	if get_child_count() == 0:
		generate_tiles()



extends PanelContainer

onready var tree = $Box/Tree


func _ready():
	tree.hide_root = false
	var root = tree.create_item(tree)
	root.set_text(0, "Things")
	
#	populate_tree( root, RPG.database.get_children() )


func populate_tree( parent, data ):
	for thing in data:
		if not thing.name in ["Hero", "StatusEffect"]:
			var itm = tree.create_item( parent )
			itm.set_text(0, thing.name)
			if "Name" in thing:
				itm.set_custom_color(0, Color(0.8, 0.3, 0.3) )
				itm.set_metadata( 0, RPG.database.get_path_to(thing) )
			else:
				itm.collapsed = true
				populate_tree( itm, thing.get_children() )

func _on_Spawn_pressed():
	var sel = tree.get_selected()
	var meta = sel.get_metadata(0)
	if meta:
		var map = get_parent().world_map
		var pos = RPG.player.cell
		map.add_thing( RPG.spawn( meta ), pos, true )

extends PopupPanel

onready var content = $Box/Content

var thing setget _set_thing

func _on_ExaminePanel_about_to_show():
	raise()
	content.clear()
	$Box/Title.text = thing.Name
	content.append_bbcode( thing.description )
	if "item" in thing.components:
		var item = thing.components.item
		content.append_bbcode( "\nweight: %dcn" % item.weight )
		if item.stackable:
			content.append_bbcode( "\ncount: %d" % item.stack )
		if item.use_type != 0:
			content.append_bbcode( "\neffect when used: %s" % item.use_effect )
			if item.use_type == 1:
				content.append_bbcode( "\n  -this item is consumed when used." )
			elif item.use_type == 2:
				content.append_bbcode( "\n  -charges left: %d" % item.charges )
			elif item.use_type == 3:
				content.append_bbcode( "\n  -this item has unlimited uses, go nuts!" )
	if "equipment" in thing.components:
		var equip = thing.components.equipment
		content.append_bbcode( "\nworn on: %s" % equip.equip_slot )
		if equip.min_damage > 0 and equip.max_damage > 0:
			content.append_bbcode( "\ndamage: %d-%d" % [equip.min_damage, equip.max_damage] )
			content.append_bbcode( "\naccuracy mod: %d" % equip.accuracy )
		if equip.armor_class != 0:
			content.append_bbcode( "\narmor bonus: %d" % equip.armor_class )
		if equip.equipped:
			content.append_bbcode( "\nthis item is equipped." )
		if equip.cursed:
			content.append_bbcode( "\nthis item is cursed!" )


func _on_ExaminePanel_popup_hide():
	get_tree().paused = false


func _on_ExaminePanel_gui_input(ev):
	if ev is InputEventKey or ev is InputEventMouseButton:
		hide()


func _set_thing( what ):
	assert "Name" in what
	thing = what
	popup_centered()
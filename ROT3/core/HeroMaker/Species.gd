extends VBoxContainer

func make_species_buttons():
	var species = DATA.get_node("Species")
	for spec in species.get_children():
		var new_button = $Box/Choices/_template.duplicate()
		$Box/Choices.add_child( new_button )
		if spec.get_position_in_parent() == 0:
			new_button.grab_focus()
		
		new_button.text = spec.name
		new_button.connect( "pressed", self, "_on_species_button_pressed", [spec] )
		new_button.connect( "mouse_entered", self, "_on_species_button_mouse_entered", [spec] )
		new_button.connect( "mouse_exited", self, "_on_species_button_mouse_exited" )
		
		$Box/Choices/_template.queue_free()

func select_species( spec ):
	pass

func show_species( spec ):
	pass

func clear_species():
	pass


func _ready():
	make_species_buttons()

func _on_species_button_pressed( spec ):
	select_species( spec )

func _on_species_button_mouse_entered( spec ):
	show_species( spec )

func _on_species_button_mouse_exited():
	clear_species()
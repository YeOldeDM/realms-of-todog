extends VBoxContainer

func draw_name_and_genus():
	$Name.text = RPG.player_data.name
	var S = "??"
	var R = "??"
	var J = "??"
	if RPG.player_data.sex in RPG.ABBREV:
		S = RPG.ABBREV[RPG.player_data.sex]
	if RPG.player_data.race in RPG.ABBREV:
		R = RPG.ABBREV[RPG.player_data.race]
	if RPG.player_data.job in RPG.ABBREV:
		J = RPG.ABBREV[RPG.player_data.job]
	$Genus.text = S+R+J

func draw_title():
	var n = ProjectSettings.get_setting("application/config/name")
	var v = "%d.%d.%d" % [ DATA.VERSION.MAJOR, DATA.VERSION.MINOR, DATA.VERSION.BABY, ]
	$Top/GameVersion.text = n+ " " +v

func _ready():
	draw_title()
	draw_name_and_genus()
	

func _on_current_hp_changed( what ):
	$HP/Bar.value = what
	$HP/Value/Current.text = str(what)

func _on_hp_changed( what ):
	$HP/Bar.max_value = what
	$HP/Value/Max.text = str(what)



func _on_InventoryMap_item_selected( what ):
	$SelectedItem.text = what.get_message_name()


func _on_World_game_time_changed( to ):
	to = int(to)
	var secs = to % 60
	var mins = to/60 % 60
	var hrs = to/60/60 % 24
	var days = to/60/60/24
	
	var txt = "day %d; %s:%s:%s" % \
		[days,
		str(hrs).pad_zeros(2),
		str(mins).pad_zeros(2),
		str(secs).pad_zeros(2)]
	$Time.text = txt

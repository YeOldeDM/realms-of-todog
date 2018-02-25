extends RichTextLabel

const COLOR_SYSTEM = "#434343"
const COLOR_COMBAT_HIT = "#ff0d45"
const COLOR_COMBAT_MISS = "#f0e03c"

const COLOR_FORTUNATE_EVENT = "#c8f94f"

const COLOR_UNFORTUNATE_EVENT = "#ed1e1e"


func message_playerdeath():
	message("You die...", COLOR_UNFORTUNATE_EVENT)

func message_healing( who, amt ):
	message( "%s are healed for %s Hitpoints!" % \
		[who.get_message_name(), str(amt)], COLOR_FORTUNATE_EVENT )


func message_cantdo():
	message( "You can't do that!" )

func message_cancel():
	message( "Action cancelled" )

func message_attack( attacker, target, damage ):
	var txt = "%s hits %s for %s points of damage!" % \
		[attacker,target,damage]
	var color = COLOR_COMBAT_HIT
	if damage <= 0:
		txt = "%s misses!" % [attacker]
		color = COLOR_COMBAT_MISS
	message( txt, color )

func message( text="", color="#ffffff" ):
	var txt = "\n[color=%s]%s[/color]" % [color, text]
	append_bbcode( txt )

func random_message():
	var choices = [
		"Never gonna give you up!",
		"Never gonna let you down!",
		"What is love!",
		"Baby don't hurt me.",
		"There's a snake in my boot!",
		"There's a boot in my peanut butter!",
		]

	var n = randi() % choices.size()
	message( choices[ n ], COLOR_FORTUNATE_EVENT )





func _ready():
	scroll_following = true
	RPG.messageboard = self
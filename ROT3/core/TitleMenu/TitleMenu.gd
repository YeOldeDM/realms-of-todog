extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	$Box/Version.text = "%d.%d.%d" % [DATA.VERSION.MAJOR, DATA.VERSION.MINOR, DATA.VERSION.BABY]

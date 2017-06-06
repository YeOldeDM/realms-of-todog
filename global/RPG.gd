extends Node

onready var _db = preload( "res://things/Database.tscn" ).instance()


func make_thing( path ):
	return _db.spawn( path )

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

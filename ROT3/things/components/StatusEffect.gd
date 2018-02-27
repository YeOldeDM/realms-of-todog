extends Node

onready var Owner = get_parent()

export(String) var status_name = "Itchy Tasty"
export(int) var duration = 3

export(Texture) var brand_texture = null

onready var life = duration

func _ready():
	if Owner:
		owner.status_effects[self.status_name] = self




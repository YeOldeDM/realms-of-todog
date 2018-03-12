extends Node

onready var Owner = get_parent()

export(String) var status_name = "Itchy Tasty"
export(int) var duration = 120	#in seconds


export(Texture) var brand_texture = null

onready var life = 0

func _ready():
	if Owner:
		owner.status_effects[self.status_name] = self


func _rpg_process(delta):
	self.life += delta
	if self.life > self.duration:
		RPG.messageboard.message("%s is no longer %s!" % [Owner.get_message_name(), status_name])
		self.queue_free()



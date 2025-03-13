extends Node

var speed : float = 30.0
var damage : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process (delta):
	global_transform.origin -= transform.basis.z.normalized() * speed * delta

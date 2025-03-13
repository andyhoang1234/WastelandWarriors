extends Area3D

var speed : float = 30.0
var damage : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process (delta):
	# move the bullet forwards
	global_transform.origin -= transform.basis.z.normalized() * speed * delta

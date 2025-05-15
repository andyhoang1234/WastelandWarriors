extends Area3D

var speed : float = 80
var damage : int = 1
var direction : Vector3 = Vector3.ZERO
var bDrop : float = 0
var dropSpeed :float = 0.2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process (delta):
	# move the bullet forwards
	bDrop = bDrop+dropSpeed
	global_transform.origin += -global_transform.basis.z * speed * delta
	global_transform.origin += -global_transform.basis.y * bDrop * delta


func _on_Bullet_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
		destroy()

func destroy() -> void:
	pass # Replace with function body.

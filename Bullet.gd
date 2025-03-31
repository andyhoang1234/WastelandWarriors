extends Area3D

var speed : float = 8.0
var damage : int = 1
var direction : Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process (delta):
	# move the bullet forwards
	global_transform.origin += -global_transform.basis.z * speed * delta



func _on_Bullet_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()


func _on_body_entered(body: Node3D) -> void:
		queue_free()

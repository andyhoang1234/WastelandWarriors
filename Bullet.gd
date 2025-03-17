extends Area3D

var speed : float = 30.0
var damage : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process (delta):
	# move the bullet forwards
	global_transform.origin -= transform.basis.z.normalized() * speed * delta

func _on_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	pass # Replace with function body.

func _on_Bullet_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
		destroy()




func destroy() -> void:
	pass # Replace with function body.

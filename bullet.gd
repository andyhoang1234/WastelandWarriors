extends Area3D

var speed: float = 30
var damage: int = 1  # Ensure the damage is exposed
var bDrop: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	bDrop = bDrop + 0.1
	global_transform.origin -= transform.basis.z.normalized() * speed * delta
	global_transform.origin -= transform.basis.y.normalized() * bDrop * delta

func _on_body_entered(body: Node3D):
	if body.has_method("take_damage"):
		body.take_damage(damage)  # Apply damage to the enemy
		queue_free()  # Destroy the bullet after hitting

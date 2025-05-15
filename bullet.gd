extends Area3D

var speed: float = 300
var damage: int = 1200  # Ensure the damage is exposed
var bDrop: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	bDrop = bDrop + 0.1
	global_transform.origin += transform.basis.y.normalized() * speed * delta
	global_transform.origin.y -= bDrop * delta

func _on_Bullet_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
		destroy()

func destroy() -> void:
	pass # Replace with function body.

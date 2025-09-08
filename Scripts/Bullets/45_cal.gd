extends Area3D


var speed: float = 100
var headshot_damage: int = 15 * Global.instakill * Global.bullet_damage_multiplier #
var damage: int = 10 * Global.instakill * Global.bullet_damage_multiplier # Ensure the damage is exposed
var bDrop: float = 0

var shooter_peer_id: int  # This will be set by the player who fired the bullet

func _ready():
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _process(delta: float) -> void:
	bDrop = bDrop + 0.01
	global_transform.origin += transform.basis.y.normalized() * speed * delta
	global_transform.origin.y -= bDrop * delta
	await get_tree().create_timer(3.0).timeout
	queue_free()
	
func _on_body_entered(body: Node3D):
	if body.has_method("take_damage"):
		body.take_damage(damage, shooter_peer_id)  # Now we pass both args
		queue_free()
	if body.has_method("take_damage_headshot"):
		body.take_damage(damage, shooter_peer_id)  # Now we pass both args
		queue_free()

extends Node3D

var health_max = 100
var health_increase = 100  # This can be set to the player's max health

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func _on_rigid_body_3d_body_entered(body: Node) -> void:
	if body.is_in_group("player"):  # Ensure the player picks up the power-up
		body.increase_max_health()  # Call the method to restore health
		queue_free()  # Remove the power-up after pickup
		print("JESSE")

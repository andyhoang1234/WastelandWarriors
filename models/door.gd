extends Node3D



func _ready():
	# Initialize or set up anything needed when the door is ready
	pass

# --- Move the door to the open or closed position ---
func move_door():
	queue_free()

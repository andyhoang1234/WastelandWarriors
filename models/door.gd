extends Node3D

# --- Parameters and state ---
var interactable = true
@export var toggle: bool = false
@export var open_position: Vector3 = Vector3(0, 0, -2) # Adjust this based on your scene
@export var closed_position: Vector3 = Vector3(0, 0, 0) # Default position

@onready var door: Node3D = $Door
var is_open := false  # Track door state

# --- Declare the signal ---
signal interacted

# --- Handle door interaction ---
func _ready():
	# Connect the door_interacted signal from the interact.gd script to this script
	var interact_script = get_node("..")  # Reference to the parent or wherever the interact script is
	interact_script.connect("door_interacted", self, "_on_interacted")  # Connect the signal to _on_interacted

# --- Respond to the interaction ---
func _on_interacted():
	if interactable:
		if toggle:
			is_open = !is_open  # Toggle state
			move_door(is_open)
		else:
			move_door(true)

# --- Move the door to the open or closed position ---
func move_door(state: bool):
	var target_position = open_position if state else closed_position
	var tween = create_tween()
	tween.tween_property(door, "position", target_position, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

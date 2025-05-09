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

func _physics_process(delta):
	pass
func _ready():
	# Connect the interacted signal to self to handle interaction
	connect("interacted", _on_interacted)
	
func _on_interacted():
	if interactable:
		if toggle:
			is_open = !is_open  # Toggle state
			move_door(is_open)
		else:
			move_door(true)

			
func move_door(state: bool):
	var target_position = open_position if state else closed_position
	var tween = create_tween()

extends Node
var toggle = false 
@export var animation_player: AnimationPlayer

fumc interact():
var door_opening = false
var door_animation_duration = 2.0  # Time for door to fully open
var open_rotation = 90.0  # Degrees to rotate door
var door_closed_rotation = 0.0  # Initial rotation (closed position)

onready var Door = $MeshInstance


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("Door")
	

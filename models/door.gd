extends Node3D


var interactable = true
@export var toggle: bool = false
@export var open_position: Vector3 = Vector3(0, 0, -2) # Adjust this based on your scene
@export var closed_position: Vector3 = Vector3(0, 0, 0) # Default position
@onready var door: Node3D = $Door


func _physics_process(delta):
	pass
			
func move_door(state: bool):
	var target_position = open_position if state else closed_position
	var tween = create_tween()
	tween.tween_property(door, "position", target_position, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

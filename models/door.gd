extends Node3D

@export var toggle: bool = false
@export var open_position: Vector3 = Vector3(0, 0, -2) # Adjust this based on your scene
@export var closed_position: Vector3 = Vector3(0, 0, 0) # Default position
@onready var door: Node3D = $Door
@onready var ray: RayCast3D = $RayCast3D

func _physics_process(delta):
	if Input.is_action_just_pressed("door") and ray.is_colliding():
		toggle = !toggle
		move_door(toggle)

func move_door(state: bool):
	var target_position = open_position if state else closed_position
	var tween = create_tween()
	tween.tween_property(door, "position", target_position, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

extends RayCast3D

var interact_cast_result
var current_cast_result
var interact_distance := 10.0  # Set a default interaction distance
var interactable = true
@export var toggle: bool = false
@export var open_position: Vector3 = Vector3(0, 0, -2) # Adjust this based on your scene
@export var closed_position: Vector3 = Vector3(0, 0, 0) # Default position
@onready var door: Node3D = $Door

@onready var camera = get_node("/root/testWorld/1/Player/Camera3D")

func _input(event):  
	if event.is_action_pressed("interact"):
		interact()

func interact_cast() -> void:
	print("interact cast")
	var space_state = camera.get_world_3d().direct_space_state
	var screen_center = get_viewport().size / 2
	var origin = camera.project_ray_origin(screen_center)
	var end = origin + camera.project_ray_normal(screen_center) * interact_distance

	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_bodies = true
	query.set_exclude([self])

	var result = space_state.intersect_ray(query)
	current_cast_result = result.get("collider")

	if current_cast_result != interact_cast_result:
		if interact_cast_result and interact_cast_result.has_user_signal("unfocused"):
			interact_cast_result.emit_signal("unfocused")

		interact_cast_result = current_cast_result

		if interact_cast_result and interact_cast_result.has_user_signal("focused"):
			interact_cast_result.emit_signal("focused")

func interact() -> void:
	if interact_cast_result:
		print("cast result")
		if interact_cast_result.has_user_signal("interacted"):
			print("interact")
			interact_cast_result.emit_signal("interacted")

func _ready() -> void:
	pass
	
func _physics_process(delta):
	pass

func _process(delta: float) -> void:
	pass
			
func move_door(state: bool):
	var target_position = open_position if state else closed_position
	var tween = create_tween()
	tween.tween_property(door, "position", target_position, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

extends RayCast3D

var interact_cast_result
var current_cast_result
var interact_distance := 10.0  # Set a default interaction distance

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

func _process(delta: float) -> void:
	pass

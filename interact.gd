extends RayCast3D

# Declare signals
signal door_interacted


var interact_cast_result
var current_cast_result
var door_buy: int
@onready var player = get_parent().get_parent()
var interact_distance := 10.0  # Set a default interaction distance
var interactable = true
@export var toggle: bool = false
@export var open_position: Vector3 = Vector3(0, 0, -2) # Adjust this based on your scene
@export var closed_position: Vector3 = Vector3(0, 0, 0) # Default position

@onready var camera = get_node("..")

func _ready() -> void:
		door_buy = 1


func _input(event):  
	if Input.is_action_just_pressed("interact"):
		interact()

# Perform ycast to detect interactable objects
func interact_cast() -> void:
	var space_state = camera.get_world_3d().direct_space_state
	var screen_center = get_viewport().size / 2
	var origin = camera.project_ray_origin(screen_center)
	var end = origin + camera.project_ray_normal(screen_center) * interact_distance

	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_bodies = true
	query.set_exclude([self])

	var result = space_state.intersect_ray(query)
	if result:
		current_cast_result = result.get("collider")
	else:
		current_cast_result = null

# Interact with detected object (e.g., door)
func interact() -> void:
	if current_cast_result:
		var door = current_cast_result.get_parent()
		
		if door and door.has_method("move_door") and player.dorrah >= Global.door_price:
			player.dorrah -= Global.door_price
			door.move_door()
			Global.door_price += 500

			# 🔄 Update price display for all remaining doors
			for d in get_tree().get_nodes_in_group("doors"):
				if d.has_method("update_price_display"):
					d.update_price_display()

		# 🧳 Pack the door if it has a pack() method
		if door and door.has_method("pack"):
			door.pack()


		if current_cast_result.get_parent().has_method("pack"):
			current_cast_result.get_parent().pack()


# Regular physics process
func _physics_process(delta):
	interact_cast()

func _process(delta: float) -> void:
	pass

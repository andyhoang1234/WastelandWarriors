extends MeshInstance3D

@export var drop_item_mesh : Mesh = BoxMesh.new()  # Replace with your item mesh
@export var drop_item_scene : PackedScene  # Drag and drop the DropItem scene here
@export var spawn_area_min : Vector3 = Vector3(-10, 0, -10)  # Minimum spawn location
@export var spawn_area_max : Vector3 = Vector3(10, 0, 10)   # Maximum spawn location
@export var spawn_interval : float = 3.0  # Time interval between drops in seconds

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = drop_item_mesh
	add_child(mesh_instance)
	var timer : Timer
# Create and set up the timer
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
func _on_timer_timeout():
	spawn_drop()

func spawn_drop():
	# Generate a random position within the defined spawn area
	var spawn_position = Vector3(
	randf_range(spawn_area_min.x, spawn_area_max.x),spawn_area_min.y,randf_range(spawn_area_min.z, spawn_area_max.z))
	# Instantiate and position the drop item
	var drop_item = drop_item_scene.instantiate()
	drop_item.transform.origin = spawn_position
	add_child(drop_item)
	# Optional: Add some randomness to the drop's physics behavior (e.g., random rotation)
	drop_item.rotation_degrees = Vector3(randf_range(0, 360), randf_range(0, 360), randf_range(0, 360))
 # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

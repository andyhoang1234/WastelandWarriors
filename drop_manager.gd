extends Node3D

@export var drop_items: Array[PackedScene]  # List of items to drop
@export var drop_area: Vector3 = Vector3(10, 5, 10)  # Size of the spawn area
@export var drop_height: float = 10.0  # Height from which items will spawn
@export var drop_interval: float = 3.0  # Time between drops

func _ready():
	start_dropping()

func start_dropping():
	var timer = Timer.new()
	timer.wait_time = drop_interval
	timer.autostart = true
	timer.timeout.connect(drop_item)
	add_child(timer)

func drop_item():
	if drop_items.is_empty():
				return  # <- This must be indented under the if statement
	var random_item = drop_items.pick_random()
	var instance = random_item.instantiate()
	# Add the instance to the scene first
	get_parent().add_child(instance)

	# Now we can safely set the position
	var random_x = randf_range(-drop_area.x / 2, drop_area.x / 2)
	var random_z = randf_range(-drop_area.z / 2, drop_area.z / 2)
	instance.global_transform = Transform3D(Basis(), Vector3(random_x, drop_height, random_z))

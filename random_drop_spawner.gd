extends Node3D
@export var drop_item_scene : PackedScene  # Reference to the DropItem scene
var timer : Timer
@export var drop_item_mesh : Mesh = BoxMesh.new()  # Replace with your item mesh
@onready var area = $Area3D  # Assuming the item has an Area3D node with a collision shape

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var drop_item = drop_item_scene.instantiate()
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 3.0
	timer.autostart = true
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = drop_item_mesh
	add_child(mesh_instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends  Node3D

var wave_scenes = [
	preload("res://Waves/Wave1.tscn"),
	preload("res://Waves/Wave2.tscn"),
	preload("res://Waves/Wave3.tscn"),
	preload("res://Waves/Wave4.tscn"),
	preload("res://Waves/Wave5.tscn"),
	preload("res://Waves/Wave6.tscn"),
	preload("res://Waves/Wave7.tscn"),
	preload("res://Waves/Wave8.tscn"),
	preload("res://Waves/Wave9.tscn"),
	preload("res://Waves/Wave10.tscn")
]

var current_wave = 1
var spawned = false

func _ready() -> void:
	spawn_wave()

func _physics_process(delta: float) -> void:
	# Check if there are any enemies left
	var enemies_exist = false
	for child in get_children():
		if "Wave" in child.name:
			enemies_exist = true
			break
		print(enemies_exist)

	# If no enemies and we haven't spawned the next wave yet
	if not enemies_exist and not spawned:
		spawn_wave()

func spawn_wave():
	if current_wave > wave_scenes.size():
		return # No more waves

	var wave_scene = wave_scenes[current_wave - 1]
	var wave_instance = wave_scene.instantiate()
	add_child(wave_instance)
	current_wave += 1
	spawned = true

func _on_wave_spawned():
	# This method can be connected to the wave scene if it emits a signal when it finishes spawning enemies
	spawned = false

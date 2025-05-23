extends Node3D

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
	preload("res://Waves/Wave10.tscn"),
	preload("res://Waves/Wave11.tscn"),
	preload("res://Waves/Wave12.tscn"),
	preload("res://Waves/Wave13.tscn"),
	preload("res://Waves/Wave14.tscn"),
	preload("res://Waves/Wave15.tscn"),
	preload("res://Waves/Wave16.tscn"),
	preload("res://Waves/Wave17.tscn"),
	preload("res://Waves/Wave18.tscn"),
	preload("res://Waves/Wave19.tscn"),
	preload("res://Waves/Wave20.tscn"),
	preload("res://Waves/Wave21.tscn")
]

var current_wave = 1
var spawn_area_size = Vector3(25, 0, 25) # Define the size of the spawn area

func _ready() -> void:
	spawn_wave()

func _physics_process(delta: float) -> void:
	var enemies_exist = false

	# Check if there are any enemies left
	for child in get_children():
		for grandchild in child.get_children():
			if grandchild != null:
				enemies_exist = true
				break # Exit the loop as soon as we find an enemy
		if enemies_exist:
			break

	# If no enemies and we haven't spawned the next wave yet
	if not enemies_exist:
		spawn_wave()

func spawn_wave():
	# Clamp current_wave to the last wave if it exceeds the total number of waves
	if current_wave > wave_scenes.size():
		current_wave = wave_scenes.size()  # Always spawn the last wave
	
	var wave_scene = wave_scenes[current_wave - 1]
	var wave_instance = wave_scene.instantiate()
	add_child(wave_instance)

	# Spawn enemies at random positions
	for enemy in wave_instance.get_children():
		if enemy.is_in_group("enemy"): # Assuming enemies are in the "enemy" group
			var random_position = Vector3(
				randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2),
				0, # Assuming y is ground level
				randf_range(-spawn_area_size.z / 2, spawn_area_size.z / 2)
			)
			enemy.position = random_position

	# Only increase wave if not the last one
	if current_wave < wave_scenes.size():
		current_wave += 1

	Global.HMult += 2
	Global.DEnemyMult += 2

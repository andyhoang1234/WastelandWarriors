extends Node3D

@onready var wave_timer: Timer = $WaveTimer
@onready var countdown_label: Label3D = $CountdownLabel

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
var spawn_area_size = Vector3(25, 0, 25)
var waiting_for_next_wave = false

func _ready() -> void:
	if wave_timer == null:
		push_error("WaveTimer node not found! Creating one manually.")
		wave_timer = Timer.new()
		wave_timer.name = "WaveTimer"
		add_child(wave_timer)

	wave_timer.wait_time = 2.0
	wave_timer.one_shot = true
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	spawn_wave()

func _physics_process(delta: float) -> void:
	if waiting_for_next_wave:
		if countdown_label != null:
			var time_left = int(ceil(wave_timer.time_left))
			countdown_label.text = "Next wave in: %d..." % time_left
		return

	var enemies_exist = false

	for child in get_children():
		for grandchild in child.get_children():
			if grandchild != null and grandchild.is_in_group("enemy"):
				enemies_exist = true
				break
		if enemies_exist:
			break

	if not enemies_exist:
		waiting_for_next_wave = true
		if countdown_label != null:
			countdown_label.visible = true
		wave_timer.start()

func _on_wave_timer_timeout() -> void:
	waiting_for_next_wave = false
	if countdown_label != null:
		countdown_label.visible = false
	spawn_wave()


func spawn_wave():
	if current_wave > wave_scenes.size():
		current_wave = wave_scenes.size()
	
	var wave_scene = wave_scenes[current_wave - 1]
	var wave_instance = wave_scene.instantiate()
	add_child(wave_instance)

	for enemy in wave_instance.get_children():
		if enemy.is_in_group("enemy"):
			var random_position = Vector3(
				randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2),
				0,
				randf_range(-spawn_area_size.z / 2, spawn_area_size.z / 2)
			)
			enemy.position = random_position

	if current_wave < wave_scenes.size():
		current_wave += 1

	Global.HMult += 2
	Global.DEnemyMult += 2

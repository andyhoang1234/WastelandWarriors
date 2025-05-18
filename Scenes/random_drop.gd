extends Node3D

@export var Powers: int = 1 # Number of power-ups to spawn

# Dictionary of power-up scenes
const POWER_SCENES := {
	"MaxHealth": preload("res://maxhealth.tscn"),
	"InstaKill": preload("res://instakill.tscn"),
}

func _ready() -> void:
	randomize()

	# Manually construct a typed array of PackedScene
	var scene_list: Array[PackedScene] = []
	for value in POWER_SCENES.values():
		scene_list.append(value as PackedScene)

	# Spawn random power-ups
	for i in Powers:
		var scene: PackedScene = scene_list[randi() % scene_list.size()]
		var instance = scene.instantiate()
		add_child(instance)

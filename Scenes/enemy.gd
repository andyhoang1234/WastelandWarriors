extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
var SPEED = 11
var enemy_health = 20

@export var powerup_scene = preload("res://maxhealth.tscn")


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	pass

func update_target_location(target_location):
	nav_agent.set_target_position(target_location)

func _physics_process(_delta):
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	
	# Check if the enemy is already at the target location
	if current_location.distance_to(next_location) > 0.1:
		look_at(next_location)  # Enemy will turn to face player

	# Vector Maths
	var new_velocity = (next_location - current_location).normalized() * SPEED
	velocity = new_velocity
	
	move_and_slide()

func take_damage(damage_amount: int):
	enemy_health -= damage_amount
	if enemy_health <= 0:
		_on_enemy_death()


# This function is called when the enemy's health reaches 0
func _on_enemy_death():
	print("Tashi has been defeated and is a d-wangchuck@gmail.com")

	# 50% chance to drop the powerup
	if randi() % 100 < 5:
		var powerup = powerup_scene.instantiate()
		var world = get_tree().get_root().get_node("testWorld")
		world.add_child(powerup)
		powerup.global_transform.origin = global_transform.origin + Vector3(0, 1, 0)

	queue_free()  # Destroy the enemy

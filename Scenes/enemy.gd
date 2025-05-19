extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
var SPEED = 3
var enemy_health = 1

@export var powerup_scene = preload("res://Scenes/randomDrop.tscn")
@export var min_dorrah_reward: int = 10  # Minimum Dorrah reward
@export var max_dorrah_reward: int = 100  # Maximum Dorrah reward

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	enemy_health += Global.HMult

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

# Take damage and reduce health
func take_damage(damage_amount: int):
	enemy_health -= damage_amount
	if enemy_health <= 0:
		_on_enemy_death()

# This function is called when the enemy's health reaches 0
func _on_enemy_death():
	# Generate a random Dorrah reward between min_dorrah_reward and max_dorrah_reward
	var dorrah_reward = randi_range(min_dorrah_reward, max_dorrah_reward)

	# Add the random Dorrah reward to the global currency
	Global.add_dorrah(dorrah_reward)

	# Print the message to the console
	print("Total Dorrah: ", Global.dorrah)

	# Drop a powerup if a random chance is met
	if randi() % 100 < 100:
		var powerup = powerup_scene.instantiate()
		var world = get_tree().get_root().get_node("testWorld")
		world.add_child(powerup)
		powerup.global_transform.origin = global_transform.origin + Vector3(0, -0.2, 0)

	queue_free()  # Destroy the enemy

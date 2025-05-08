extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
var SPEED = 3.5
var enemy_health = 20

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

# Function to handle taking damage
func take_damage(damage_amount: int):
	enemy_health -= damage_amount
	if enemy_health <= 0:
		queue_free()

# This function is called when the enemy's health reaches 0
func _on_enemy_death():
	print(name + " has been defeated!")
	queue_free()  # Destroy the enemy

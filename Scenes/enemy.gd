extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
var SPEED = 0
var enemy_health = 100
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var some_condition = true

func _ready():
	if some_condition:  # Indented correctly now
		do_something()  # This line is indented and belongs to _ready()

func do_something():
	print("Something happened!")

func update_target_location(target_location):
	nav_agent.set_target_position(target_location)

func _physics_process(_delta):
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	
	# Check if the enemy is already at the target location
	if current_location.distance_to(next_location) > 0.1:  # Indented correctly now
		look_at(next_location)  # Enemy will turn to face player

	# Vector Maths
	var new_velocity = (next_location - current_location).normalized() * SPEED
	
	velocity = new_velocity
	
# This function is called when the enemy takes damage
func take_damage(amount):
	enemy_health -= amount
	if enemy_health <= 0:
		_on_enemy_death()

# This function is called when the enemy's health reaches 0
func _on_enemy_death():
	print(name + " has been defeated!")
	queue_free()  # Destroy the enemy

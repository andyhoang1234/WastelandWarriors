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
	
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		#print(collision.collider.get_collider().name)
		if collision.get_collider().name == "StaticBody3D":
			print(collision.get_collider().name)
		if collision.get_collider().is_in_group("Bullet"):
	# Handle collision with a bullet
			reduce_health(100)
		if "1" in collision.get_collider().name:
			
			collision.get_collider().reduce_health(100)

func reduce_health(amount):
	enemy_health -= amount
	print(enemy_health)
	if enemy_health < 0:
			# The player dies. 
			# Go back to the main menu. This can be changed to any scene in the future.
			get_tree().change_scene_to_file("res://Menus/main_menu.tscn")

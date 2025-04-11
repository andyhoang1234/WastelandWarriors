extends RayCast3D  # The script extends RayCast3D, meaning it will inherit properties and methods for 3D raycasting functionality.

# Declare variables to hold the cast result and the current interactable object
var interact_cast_result  # Stores the last object interacted with via raycast.
var current_cast_result  # Stores the current object being interacted with via raycast.
var interact_distance  # The maximum distance for raycasting to detect objects.
@onready var camera = "/root/testWorld/1/Player/Camera3D"

# This function is called whenever an input event occurs, such as pressing a key or clicking the mouse.
func _input(event):  
	# Check if the "interact" action (defined in input settings) is pressed.
	if event.is_action_pressed("interact"):
		interact()  # Call the interact function when the player presses the interact button.

# Function to perform a raycast for interaction, returning the object that is being interacted with.
func interact_cast() -> void:
	print("interact cast")
	# Get the player's camera (likely the main camera from a global player controller)
	var camera = Global.player.CAMERA_CONTROLLER
	# Get the 3D space state for the camera (this allows interaction with physics)
	var space_state = camera.get_world_3d().direct_space_state
	# Calculate the center of the screen in viewport coordinates
	var screen_center = get_viewport().size / 2
	# Get the origin of the raycast by projecting a ray from the center of the screen
	var origin = camera.project_ray_origin(screen_center)
	# Calculate the direction (normal) of the raycast based on the camera view
	var end = origin + camera.project_ray_normal(screen_center) * interact_distance
	# Set up the raycast query with the origin and end points
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_bodies = true  # Ensure the raycast will detect objects (colliders).
	query.set_exclude([self])  # Exclude this object (the one this script is attached to) from being interacted with.
	
	# Perform the raycast and get the result, which returns information about the detected object.
	var result = space_state.interact_ray(query)
	
	# Get the current object the ray is hitting (the collider).
	current_cast_result = result.get("collider")
	# Get the collider this RayCast3D is attached to (used for comparison later).
	current_cast_result = get_collider()
	
	# If the current cast result is different from the previous one (something new was hit):
	if current_cast_result != interact_cast_result:
		# If there was a previously interacted object and it has a "unfocused" signal, emit that signal.
		if interact_cast_result and interact_cast_result.has_user_signal("unfocused"):
			interact_cast_result.emit_signal("unfocused")
		
		# Update the interact_cast_result to the new object hit by the raycast.
		interact_cast_result = current_cast_result
		
		# If the new cast result has a "focused" signal, emit that signal (indicating focus).
		if interact_cast_result and interact_cast_result.has_user_signal("focused"):
			interact_cast_result.emit_signal("focused")

# Function to handle the interaction logic when the "interact" action is triggered.
func interact() -> void:
	if interact_cast_result:
		print("cast result")
	# If the interactable object has a user signal "interacted", emit that signal.
	if interact_cast_result and interact_cast_result.has_user_signal("interacted"):
		print("interact")
		interact_cast_result.emit_signal("interacted")

# Called when the node enters the scene tree for the first time (initialization).
func _ready() -> void:
	pass  # Placeholder, no functionality here yet.

# Called every frame; the 'delta' parameter is the time passed since the last frame.
func _process(delta: float) -> void:
	pass  # Placeholder, no functionality here yet.

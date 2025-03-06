extends Node

# Export the Enemy scene to be spawned
@export var enemy_scene: PackedScene
# Define the min and max number of enemies to spawn
@export var min_enemies: int = 3
@export var max_enemies: int = 10
# Position where enemies will spawn
@export var spawn_area: Vector3 = Vector3(10, 0, 10)

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_enemies()

# Function to spawn the random number of enemies
func spawn_enemies():
	# Randomly choose the number of enemies to spawn
	var num_enemies = randi_range(2, 10)
	
	for i in range(num_enemies):
		# Random position within the spawn area
		var spawn_position = Vector3(
			randf_range(-10, 10),
			0,  # Assuming a 2D plane for spawn height, adjust as needed
			randf_range(-10, 10)
		)

		# Spawn the enemy
		var enemy = enemy_scene.instantiate()
		enemy.transform.origin = spawn_position
		add_child(enemy)  # Add enemy to the scene

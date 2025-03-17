extends Node  # or any other node

func _process(delta):
	# Access the scene tree from the root node
	var tree = get_node("/root")

	# Check if there are no enemies in the "enemy" group
	if tree.get_nodes_in_group("enemy").empty():
		# All enemies have been defeated, so proceed to the next level
		tree.change_scene("res://next_level.tscn")  # Make sure this path is correct

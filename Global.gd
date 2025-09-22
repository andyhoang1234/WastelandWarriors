extends Node

var bullet_damage_multiplier: int = 1
var Lose
var PauseMenu
var TabMenu
var MultiplayerMainMenu

var HMult: float = 0.0
var DEnemyMult: int = 0

var door_price: int = 15000 # Starting price of doors

# Dictionary to store dorrah per player peer_id
var dorrah_per_player := {}

var instakill = 1
var health
var amount

func _add_dorrah(type, shooter_peer_id):
	var target_id = shooter_peer_id
	var player = find_player(target_id)
	if player:
		randomize()
		give_random_currency()
		player.dorrah += amount
	
	
# Global.gd (autoload)

func find_player(target_id: int) -> Node:
	var root = get_tree().get_current_scene()
	if root == null:
		return null  # No scene loaded yet
	
	return _search(root, target_id)

func _search(node: Node, target_id: int) -> Node:

	if node.get("player_peer_id") == target_id:
		return node
	for child in node.get_children():
		var found = _search(child, target_id)
		if found:
			return found
	return null
	
func give_random_currency() -> void:
	# Generate a random integer between min_amount and max_amount (inclusive)
	amount = randi() % (100 - 50 + 1) + 50
	

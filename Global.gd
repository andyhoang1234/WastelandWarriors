extends Node

var bullet_damage_multiplier: int = 1
var Lose
var PauseMenu
var TabMenu

var HMult: float = 0.0
var DEnemyMult: int = 0

var door_price: int = 15000 # Starting price of doors

# Dictionary to store dorrah per player peer_id
var dorrah_per_player := {}

var instakill = 1
var health

func _ready():
	dorrah_per_player.clear()

func initialize_player(peer_id: int) -> void:
	if not dorrah_per_player.has(peer_id):
		set_dorrah(peer_id, 0)

func get_dorrah(peer_id: int) -> int:
	return dorrah_per_player.get(peer_id, 0)

func set_dorrah(peer_id: int, value: int) -> void:
	dorrah_per_player[peer_id] = value

func add_dorrah(peer_id: int, amount: int) -> void:
	var current = get_dorrah(peer_id)
	set_dorrah(peer_id, current + amount)
	print("Player", peer_id, "now has dorrah:", get_dorrah(peer_id))

func subtract_dorrah(peer_id: int, amount: int) -> void:
	set_dorrah(peer_id, max(0, get_dorrah(peer_id) - amount))

# Server -> Client sync dorrah RPC
@rpc("any_peer", "call_remote")
func sync_dorrah(peer_id: int, new_value: int) -> void:
	dorrah_per_player[peer_id] = new_value
	print("Synced dorrah for player", peer_id, "to", new_value)

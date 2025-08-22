extends Node


var bullet_damage_multiplier: int = 1
var Lose
var PauseMenu
var TabMenu

var HMult:float
var DEnemyMult:int

var door_price: int = 15000 # Starting price of doors

var dorrah_per_player := {}

var instakill
var health

func high_resolution_display_mode(status):
	if status == true:
		if OS.get_name() == "macOS":
			get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
			DisplayServer.window_set_size(Vector2i(2560, 1440))
			get_window().move_to_center()

func initialize_player(peer_id: int):
	if not dorrah_per_player.has(peer_id):
		set_dorrah(peer_id, 0)  # Initialize to 0 or any starting value

func _ready():
	dorrah_per_player.clear()
	# Initialize multipliers properly
	HMult = 0
	DEnemyMult = 0

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

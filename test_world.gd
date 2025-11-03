extends Node

const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = get_node_or_null("CanvasLayer/MainMenu/Control/MarginContainer/VBoxContainer/AddressEntry")
@onready var PauseMenu = $CanvasLayer/PauseMenu
@onready var OptionsMenu = $CanvasLayer/OptionsMenu
@onready var ControlsMenu = $CanvasLayer/ControlsMenu
@onready var Lose = $CanvasLayer/Lose
@onready var MultiplayerMainMenu = $CanvasLayer/MultiplayerMainMenu

var IpAddress

@onready var Player = preload("res://player.tscn")
var tracked = false
var player
var toggle = true
var bulletScene = preload("res://Bullet.tscn")



func _ready() -> void:
	Global.PauseMenu = $CanvasLayer/PauseMenu
	Global.Lose = $CanvasLayer/Lose
	Global.MultiplayerMainMenu = $CanvasLayer/MultiplayerMainMenu
	print("MultiplayerMainMenu node:", Global.MultiplayerMainMenu)
	
	var upnp = UPNP.new()
	upnp.discover(2000, 2, "InternetGatewayDevice")
	IpAddress = upnp.query_external_address()

func _physics_process(_delta):
	if tracked:
		get_tree().call_group("enemy", "update_target_location", player.global_transform.origin)

func update_dorrah_label(new_value: int):
	var label = $CanvasLayer/DorrahLabel  # Adjust path to your label
	if label:
		label.update_label(new_value)

# Called when a new peer connects (server only)
func _on_peer_connected(id: int) -> void:
	add_player(id)

# Called when a peer disconnects (server only)
func _on_peer_disconnected(id: int) -> void:
	remove_player(id)

# Main menu buttons 
func _on_single_player_button_pressed():
	main_menu.hide()
	multiplayer.multiplayer_peer = enet_peer
	add_player(multiplayer.get_unique_id())

func _on_main_menu_options_pressed() -> void:
	OptionsMenu.show()

func _on_quit_pressed() -> void:
	get_tree().quit()

@rpc("any_peer", "call_local")
func sync_pause(paused: bool):
	get_tree().paused = paused
	if paused:
		PauseMenu.show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		PauseMenu.hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(_event):
	if Input.is_action_just_pressed("pause"):
		if toggle:
			toggle = false
			rpc("sync_pause", true)  # Broadcast pause to all peers
		else:
			toggle = true
			rpc("sync_pause", false)  # Broadcast unpause

func add_player(peer_id: int) -> void:
	if get_node_or_null(str(peer_id)):
		return # Player already exists
	player = Player.instantiate()
	player.name = str(peer_id)
	player.player_peer_id = peer_id
	add_child(player)
	tracked = true


func remove_player(peer_id: int) -> void:
	var player_node = get_node_or_null(str(peer_id))
	if player_node:
		player_node.queue_free()

# Pause menu buttons 

func _on_resume_pressed() -> void:
	get_tree().paused = false
	PauseMenu.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_main_menu_pressed() -> void:
	get_tree().paused = true
	main_menu.show()
	PauseMenu.hide()

# Options Menu Buttons
func _on_back_button_pressed() -> void:
	OptionsMenu.hide()

func _on_controls_button_pressed() -> void:
	ControlsMenu.show()

# Controls Menu button
func _on_back_options_button_pressed() -> void:
	ControlsMenu.hide()

# Lose screen
func _on_respawn_button_pressed() -> void:
	pass # Replace with function body.

func _on_menu_lose_button_pressed() -> void:
	main_menu.show()
	Lose.hide()

# Host button pressed - start server
func _on_host_button_pressed() -> void:
	main_menu.hide()
	
	var err = enet_peer.create_server(PORT)
	if err != OK:
		push_error("Failed to create server on port %d" % PORT)
		return
	
	multiplayer.multiplayer_peer = enet_peer
	
	# Connect signals for player join/leave
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	# Add the server player (peer ID 1)
	add_player(multiplayer.get_unique_id())
	
	# Optional: UPnP port mapping
	# upnp_setup()

# Join button pressed - connect to server
func _on_join_button_pressed() -> void:
	main_menu.hide()
	
	var err = enet_peer.create_client(address_entry.text, PORT)
	if err != OK:
		push_error("Failed to connect to server at %s:%d" % [address_entry.text, PORT])
		return
	else:
		print("Connected to: " % [address_entry.text, PORT])
	
	multiplayer.multiplayer_peer = enet_peer
	
	# You can connect to signals here if needed, e.g.:
	# multiplayer.peer_connected.connect(_on_peer_connected)
	# multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func upnp_setup() -> void:
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, "UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), "UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, "UPNP Port Mapping Failed! Error %s" % map_result)
	

func _on_multiplayer_pressed() -> void:
	main_menu.hide()
	MultiplayerMainMenu.show()

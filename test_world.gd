extends Node


const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()


@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = get_node_or_null("CanvasLayer/MainMenu/Control/MarginContainer/VBoxContainer/AddressEntry")
@onready var hud = $CanvasLayer/HUD
@onready var PauseMenu = $CanvasLayer/PauseMenu
@onready var OptionsMenu = $CanvasLayer/OptionsMenu
@onready var ControlsMenu = $CanvasLayer/ControlsMenu
@onready var health_bar = $CanvasLayer/HUD/HealthBar
@onready var Lose = $CanvasLayer/Lose
@onready var TabMenu = $CanvasLayer/TabMenu

@onready var Player = preload("res://player.tscn")
#@onready var Player = $Player
var tracked = false
var player
var toggle = true
var bulletScene = preload("res://Bullet.tscn")

func _ready() -> void:
	Global.PauseMenu = $CanvasLayer/PauseMenu
	Global.Lose = $CanvasLayer/Lose

func _physics_process(_delta):
	if tracked:
		get_tree().call_group("enemy", "update_target_location", player.global_transform.origin)

func _input(_event):
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused == false:
			get_tree().paused = true
			Global.PauseMenu.show()
			hud.hide()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func update_dorrah_label(new_value: int):
	var label = $CanvasLayer/DorrahLabel  # Adjust path to your label
	if label:
		label.update_label(new_value)
		print("Updating dorrah label to", new_value)

func _unhandled_input(_event):
	if Input.is_action_just_pressed("pause"):
		if toggle:
			toggle = false
			get_tree().paused = true
			PauseMenu.show()
			hud.hide()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif !toggle:
			toggle = true
			get_tree().paused = false
			PauseMenu.hide()
			hud.show()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_pressed("tab"):
		TabMenu.show()
	else:
		TabMenu.hide()

#main menu buttons 
func _on_single_player_button_pressed():
	main_menu.hide()
	hud.show()
	#multiplayer.multiplayer_peer = enet_peer
	add_player(multiplayer.get_unique_id())

func _on_main_menu_options_pressed() -> void:
	OptionsMenu.show()

func _on_quit_pressed() -> void:
	get_tree().quit()

func add_player(peer_id):
	player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
	tracked = true
	player.health_changed.connect(update_health_bar)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func update_health_bar(health):
	health_bar.value = health

#pause menu buttons 
func _on_resume_pressed() -> void:
	get_tree().paused = false
	PauseMenu.hide()
	hud.show()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_main_menu_pressed() -> void:
	get_tree().paused = true
	main_menu.show()
	PauseMenu.hide()
	hud.hide()

#Options Menu Buttons
func _on_back_button_pressed() -> void:
	OptionsMenu.hide()

func _on_controls_button_pressed() -> void:
	ControlsMenu.show()

#Controls Menu button
func _on_back_options_button_pressed() -> void:
	ControlsMenu.hide()

#Lose sceen
func _on_respawn_button_pressed() -> void:
	pass # Replace with function body.

func _on_menu_lose_button_pressed() -> void:
	main_menu.show()
	Lose.hide()
	hud.hide()


func _on_host_button_pressed():
	main_menu.hide()
	hud.show()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	
	#upnp_setup()
func _on_join_button_pressed():
	main_menu.hide()
	hud.show()
	
	enet_peer.create_client(address_entry.text, PORT)
	multiplayer.multiplayer_peer = enet_peer

func _on_multiplayer_spawner_spawned(node):
	if node.is_multiplayer_authority():
		node.health_changed.connect(update_health_bar)
func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, "UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), "UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, "UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())

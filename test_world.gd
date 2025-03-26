extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = get_node_or_null("CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry")
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/HealthBar
@onready var PauseMenu = $CanvasLayer/PauseMenu

@onready var Player = preload("res://player.tscn")
#@onready var Player = $Player
var tracked = false
var player
var toggle = true
var bulletScene = preload("res://Bullet.tscn")
var bulletSpawn


func _physics_process(_delta):
	if tracked:
		get_tree().call_group("enemy", "update_target_location", player.global_transform.origin)

func _unhandled_input(_event):
	if Input.is_action_just_pressed("pause"):
		if toggle:
			toggle = false
			get_tree().paused = true
			PauseMenu.show()
			hud.hide()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			toggle = true
			get_tree().paused = false
			PauseMenu.hide()
			hud.show()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

#main menu buttons 
func _on_single_player_button_pressed():
	main_menu.hide()
	hud.show()
	#multiplayer.multiplayer_peer = enet_peer
	add_player(multiplayer.get_unique_id())


func _on_quit_pressed() -> void:
	get_tree().quit()

func add_player(peer_id):
	player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
	tracked = true
	if player.is_multiplayer_authority():
		player.health_changed.connect(update_health_bar)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func update_health_bar(health_value):
	health_bar.value = health_value

#pause menu buttons 
func _on_resume_pressed() -> void:
	get_tree().paused = false
	PauseMenu.hide()
	hud.show()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_main_menu_pressed() -> void:
	get_tree().paused = true
	print("go to main menu")
	main_menu.show()
	PauseMenu.hide()
	hud.hide()

	# remove player...
	# Hide the rest of the scene
	
	


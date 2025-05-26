extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = get_node_or_null("CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry")
@onready var hud = $CanvasLayer/HUD
@onready var PauseMenu = $CanvasLayer/PauseMenu
@onready var OptionsMenu = $CanvasLayer/OptionsMenu
@onready var ControlsMenu = $CanvasLayer/ControlsMenu
@onready var health_bar = $CanvasLayer/HUD/HealthBar
@onready var Lose = $CanvasLayer/Lose

@onready var Player = preload("res://player.tscn")
#@onready var Player = $Player
var tracked = false
var player
var toggle = true
var bulletScene = preload("res://Bullet.tscn")

func _ready() -> void:
	Global.PauseMenu = $CanvasLayer/PauseMenu

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


func _on_menu_button_pressed() -> void:
	main_menu.show()
	Lose.hide()
	hud.hide()

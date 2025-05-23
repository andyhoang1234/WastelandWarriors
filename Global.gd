extends Node

var bullet_damage_multiplier: int = 1
var PauseMenu
var aiming

var HMult:float
var DEnemyMult:int

var instakill
var health
var dorrah: int = 0

func high_resolution_display_mode(status):
	if status == true:
		if OS.get_name() == "macOS":
			get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
			DisplayServer.window_set_size(Vector2i(2560, 1440))
			get_window().move_to_center()

func _ready():
	high_resolution_display_mode(true)
	HMult == 0
	DEnemyMult ==0

func add_dorrah(amount: int):
	dorrah += amount

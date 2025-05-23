extends Node

var PauseMenu
var aiming
var HMult:float
var DEnemyMult:int
var instakill
var health
var dorrah: int = 0

# if status is true, increases the size of the window and scales on-screen elements to window size
# allows for better viewing on retina (or similar resolution) displays
func high_resolution_display_mode(status):
	if status == true:
		if OS.get_name()=="macOS": # Checks if MacOS. Unsure if required.
			get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT # scales UI elements to window size.
			DisplayServer.window_set_size(Vector2i(2560, 1440)) # Sets windows dimensions
			get_window().move_to_center() # Centres the screen

func _ready():
	high_resolution_display_mode(true)
	HMult == 0
	DEnemyMult ==0

func add_dorrah(amount: int):
	dorrah += amount
	print("Dorrah Total: ", dorrah)  

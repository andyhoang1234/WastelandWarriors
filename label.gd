extends Label

@onready var player := get_tree().get_first_node_in_group("players")


func _ready():
	update_label()

func update_label(new_value: int = -1):
	if new_value >= 0:
		text = "Dorrah: " + str(new_value)
	else:
		if player:
			var peer_id = player.get_multiplayer_authority()
			text = "Dorrah: " + str(Global.get_dorrah(peer_id))
	print("Dorrah label text set to:", text)

func update_dorrah_label(new_value: int):
	var dorrah_label = $CanvasLayer/DorrahLabel  # Make sure this path is correct!
	if dorrah_label:
		dorrah_label.update_label(new_value)

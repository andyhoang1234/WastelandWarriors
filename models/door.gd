extends Node3D


@onready var price_label: Label3D = $"../Label3D"

func _ready():
	# Initialize or set up anything needed when the door is ready
	pass
	add_to_group("doors")
	update_price_display()


func update_price_display():
	print("Updating label for door: ", self.name)
	price_label.text = str(Global.door_price)

# --- Move the door to the open or closed position ---
func move_door():
	price_label.visible = false
	queue_free()

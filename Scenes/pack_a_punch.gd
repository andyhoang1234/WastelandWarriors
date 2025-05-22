extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func pack():
	if Global.dorrah >= 50:
		if Global.bullet_damage_multiplier <= 8:
			Global.dorrah -= 50
			Global.bullet_damage_multiplier *= 2.0

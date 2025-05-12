extends Area3D

signal max_health_powerup_collected

@export var health_increase_amount : int = 20

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		area.increase_max_health(health_increase_amount)
		emit_signal("max_health_powerup_collected")
		queue_free()

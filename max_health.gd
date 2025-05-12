extends Area3D

@export var is_one_time_use := true

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
	if body.has_method("restore_health_to_max"):
		body.restore_health_to_max()
		if is_one_time_use:
			queue_free()

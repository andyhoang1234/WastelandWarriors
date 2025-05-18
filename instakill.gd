extends Area3D

@export var is_one_time_use := true
@export var float_speed := 1.0  # Speed of bobbing
@export var float_amplitude := 0.001  # Height of bobbing
@export var rotate_speed = 0.01

var float_timer := 0.0

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
	if body.has_method("insta_kill"):
		body.insta_kill()
		queue_free()

func _physics_process(delta: float) -> void:
	float_timer += delta * float_speed
	var offset_y = sin(float_timer) * float_amplitude
	global_position = global_position + Vector3(0, offset_y, 0)
	global_rotation = global_rotation + Vector3(0, rotate_speed, 0)

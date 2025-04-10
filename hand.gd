extends Node3D

const ADS_LERP = 30
@export var default_position : Vector3
@export var ads_position : Vector3


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("fire2"):
		transform.origin = transform.origin.lerp(ads_position, ADS_LERP * delta)
	else: 
		transform.origin = transform.origin.lerp(default_position, ADS_LERP * delta)

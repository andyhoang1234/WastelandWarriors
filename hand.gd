extends Node3D

const ADS_LERP = 15.0

@onready var default_position = get_parent().position + Vector3(0.2, -1.55, -0.2)
@onready var ads_position = get_node('Llewlac/ads').position
@onready var adsfov = 40.0
@onready var norfov = 90.0


func _process(delta):
	var camera = get_parent()
	
	# Update aiming state
	if Input.is_action_pressed("fire2"):
		Global.aiming = true
	else:
		Global.aiming = false
	
	# Interpolate FOV and position
	var target_fov = adsfov if Global.aiming else norfov
	camera.fov = lerp(camera.fov, target_fov, delta * ADS_LERP)
	
	var target_position = ads_position if Global.aiming else default_position
	transform.origin = transform.origin.lerp(target_position, delta * ADS_LERP)

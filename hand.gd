extends Node3D

const ADS_LERP = 15.0

@export var weapon_scenes: Array[PackedScene] = []

var weapons: Array[Node3D] = []
var current_weapon_index: int = 0
var current_weapon: Node3D

@onready var ads_position = get_parent().get_node("Eye").position
var adsfov := 40.0
var norfov := 90.0

var aiming
@onready var parentcam = get_parent()
@onready var default_position = position


func _ready():
	for packed_scene in weapon_scenes:
		if packed_scene:
			var weapon = packed_scene.instantiate()
			add_child(weapon)
			weapons.append(weapon)
		else:
			push_error("Invalid PackedScene in weapon_scenes.")

	if weapons.is_empty():
		push_error("No weapons were loaded.")
		return

	switch_weapon(0)


func _process(delta):
	print(parentcam)
	if current_weapon == null:
		return

	var camera = get_parent()

	aiming = Input.is_action_pressed("fire2")
	
	if aiming == true:
		get_parent()
		
	
	var target_fov = adsfov if aiming else norfov
	camera.fov = lerp(camera.fov, target_fov, delta * ADS_LERP)

	var target_position = ads_position if aiming else default_position
	current_weapon.transform.origin = current_weapon.transform.origin.lerp(target_position, delta * ADS_LERP)
	


func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == 4:  # Scroll Up
			switch_weapon((current_weapon_index + 1) % weapons.size())
		
		elif event.button_index == 5:  # Scroll Down
			switch_weapon((current_weapon_index - 1 + weapons.size()) % weapons.size())
			
	if event is InputEventMouseMotion:
		if aiming == true:
			get_parent().get_parent().rotate_y(-event.relative.x * .0005)
			parentcam.rotate_x(-event.relative.y * .0005)
			parentcam.rotation.x = clamp(parentcam.rotation.x, -PI/2, PI/2)
			
		else:
			get_parent().get_parent().rotate_y(-event.relative.x * .005)
			parentcam.rotate_x(-event.relative.y * .005)
			parentcam.rotation.x = clamp(parentcam.rotation.x, -PI/2, PI/2)


func switch_weapon(index: int) -> void:
	if index == current_weapon_index or index < 0 or index >= weapons.size():
		return

	# Disable old weapon
	if current_weapon:
		current_weapon.visible = false
		if current_weapon.has_method("set_active"):
			current_weapon.call("set_active", false)

	current_weapon_index = index
	current_weapon = weapons[index]

	# Enable new weapon
	current_weapon.visible = true
	if current_weapon.has_method("set_active"):
		current_weapon.call("set_active", true)

extends Node3D

const ADS_LERP = 15.0

@export var weapon_scenes: Array[PackedScene] = []

var weapons: Array[Node3D] = []
var current_weapon_index: int = 0
var current_weapon: Node3D

@onready var ads_position = get_parent().get_node("Eye").position
var adsfov := 40.0
var norfov := 90.0
@onready var crosshair = $"../../CenterContainer"

var aiming
@onready var parentcam = get_parent()
@onready var default_position = position

@export var lag_speed: float
var lagged_rotation := Vector3.ZERO

var sway_amount := 0.00005  # Controls how intense the sway is
var sway_speed := 2.0  # Speed of sway movement
var sway_timer := 0.0
var sway_offset := Vector3.ZERO
var target_position


func _ready():
	
	lagged_rotation = global_rotation

	for packed_scene in weapon_scenes:
		if packed_scene:
			var weapon = packed_scene.instantiate()
			add_child(weapon)
			weapon.visible = false  # Hide all weapons by default
			if weapon.has_method("set_active"):
				weapon.call("set_active", false)
			weapons.append(weapon)
		else:
			push_error("Invalid PackedScene in weapon_scenes.")

	if weapons.is_empty():
		push_error("No weapons were loaded.")
		return

	# Activate only the first weapon
	current_weapon_index = 0
	current_weapon = weapons[0]
	current_weapon.visible = true
	if current_weapon.has_method("set_active"):
		current_weapon.call("set_active", true)


func _process(delta):
	
	var target_rotation = get_parent().global_rotation

	# Interpolate toward the parent's global rotation
	lagged_rotation.x = lerp_angle(lagged_rotation.x, target_rotation.x, delta * lag_speed)
	lagged_rotation.y = lerp_angle(lagged_rotation.y, target_rotation.y, delta * lag_speed)

	# Apply the lagged rotation (overwrite inherited transform)
	#if aiming == true:
		#global_rotation = lagged_rotation
	
	parentcam.rotation.z = 0
	
	if aiming == true:
		
		crosshair.hide()
		
		
		target_position = ads_position
		lag_speed = 100.0
		
		# Increase sway timer
		sway_timer += delta * sway_speed

		# Generate smooth random offsets using sin/cos for smooth sway
		sway_offset.x = sin(sway_timer * 1.1) * sway_amount
		sway_offset.y = cos(sway_timer * 1.3) * sway_amount

		# Apply sway to camera rotation
		parentcam.rotation.x += sway_offset.y
		parentcam.rotation.y += sway_offset.x
		
	else: 
		target_position = default_position
		lag_speed = 200.0
		sway_timer = 0.0
		
		crosshair.show()
	
	if current_weapon == null:
		return

	var camera = get_parent()

	aiming = Input.is_action_pressed("fire2")
		
	
	var target_fov = adsfov if aiming else norfov
	camera.fov = lerp(camera.fov, target_fov, delta * ADS_LERP)
	
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

	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				if weapons.size() >= 1:
					switch_weapon(0)
			KEY_2:
				if weapons.size() >= 2:
					switch_weapon(1)
			KEY_3:
				if weapons.size() >= 3:
					switch_weapon(2)
			KEY_4:
				if weapons.size() >= 4:
					switch_weapon(3)
			KEY_5:
				if weapons.size() >= 5:
					switch_weapon(4)


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

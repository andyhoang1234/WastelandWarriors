extends Node

# Gun Modifiers
var maxAmmo : int = 12
var recoil_speed = 5.0
var bulletScene = preload("res://Scripts/Bullets/9mm.tscn")
var recoil_distance := 0.1 # Recoil amount along local Z-axis
var recoil_rotation_up : float = 0.01
var recoil_rotation_side = -0.005
@export var fireRate: float = 0.1

# Internal State
var active := false
var canShoot := true
var timeSinceLastShot := 0.0
var ammo : int = 100
@onready var gun = $"1911"
@onready var bulletSpawn = $bulletSpawn 
@onready var world = get_node("/root/testWorld")
var original_transform: Transform3D
var original_gun_z_rotation: float
var isRecoiling = false
@onready var weapon = $"." # The weapon node

@onready var hand = get_parent()
@onready var cam = hand.get_parent()

func _ready():
	original_transform = hand.transform
	original_gun_z_rotation = gun.rotation.z
	reload()
func reload():
	ammo = maxAmmo
	
func set_active(value: bool) -> void:
	active = value

func _physics_process(delta):
	if not active:
		return

	if Input.is_action_just_pressed("shoot") and canShoot and ammo > 0:
		var bullet = bulletScene.instantiate()
		world.add_child(bullet)
		bullet.global_transform = bulletSpawn.global_transform
		bullet.scale = Vector3(0.01, 0.01, 0.01)
		ammo -= 1

		# Apply recoil in local Z-axis
		var recoil_offset = hand.basis.z.normalized() * recoil_distance
		hand.transform.origin += recoil_offset

		# Gun tilt rotation recoil
		gun.rotation.z -= recoil_rotation_up * 4

		# Camera recoil
		if cam.rotation.x <= 1.52 and cam.rotation.x >= -1.52:
			cam.rotation.x += recoil_rotation_up

		cam.rotation.y = lerp(cam.rotation.y, randf_range(-recoil_rotation_side, recoil_rotation_side), 0.5)

		canShoot = false
		timeSinceLastShot = 0.0
		isRecoiling = true
	elif not canShoot:
		timeSinceLastShot += delta
		if timeSinceLastShot >= fireRate:
			canShoot = true

	# Smooth return to original position and rotation
	
	if isRecoiling:
		hand.transform.origin = hand.transform.origin.lerp(original_transform.origin, recoil_speed * delta)

		# Smoothly restore gun's z-rotation
		gun.rotation.z = lerp(gun.rotation.z, original_gun_z_rotation, recoil_speed * delta)

		# Once recoil position is restored, stop recoil state
		hand.transform = hand.transform.interpolate_with(original_transform, recoil_speed * delta)
		if hand.transform.origin.distance_to(original_transform.origin) < 0.001:
			hand.transform = original_transform
			gun.rotation.z = original_gun_z_rotation
			isRecoiling = false
	if Input.is_action_just_pressed("reload"):
		reload()

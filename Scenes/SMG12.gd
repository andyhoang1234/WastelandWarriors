extends Node

# Gun Modifiers
var maxAmmo : int = 28
var recoil_speed = 7.0
var bulletScene = preload("res://Bullet.tscn")
var recoil_distance = 0.05 # Recoil amount along local Z-axis
var recoil_rotation_up : float = 0.005
var recoil_rotation_side = -0.005
@export var fireRate: float = 0.05

# Internal State
var recoil_rotation_side_min = recoil_rotation_side
var recoil_rotation_side_max = recoil_rotation_side * -1
var active := false
var canShoot := true
var timeSinceLastShot := 0.0
var ammo : int = 0
@onready var bulletSpawn = $bulletSpawn 
@onready var world = get_node("/root/testWorld")
var original_transform: Transform3D
var isRecoiling = false
@onready var weapon = $"." # The weapon node

@onready var hand = get_parent()
@onready var cam = hand.get_parent()

func _ready():
	original_transform = hand.transform

func reload():
	ammo = maxAmmo

func set_active(value: bool) -> void:
	active = value

func _physics_process(delta):

	if not active:
		return

	if Input.is_action_pressed("shoot") and canShoot and ammo > 0:
		var bullet = bulletScene.instantiate()
		world.add_child(bullet)
		bullet.global_transform = bulletSpawn.global_transform
		bullet.scale = Vector3(0.01, 0.01, 0.01)
		ammo -= 1

		# Apply recoil in local Z-axis
		var recoil_offset = hand.basis.z.normalized() * recoil_distance
		hand.transform.origin += recoil_offset
		if cam.rotation.x <= 1.52 and cam.rotation.x >= -1.52:
			cam.rotation.x += recoil_rotation_up
			
		cam.rotation.y += randf_range(recoil_rotation_side_min, recoil_rotation_side_max)

		canShoot = false
		timeSinceLastShot = 0.0
		isRecoiling = true

	elif not canShoot:
		timeSinceLastShot += delta
		if timeSinceLastShot >= fireRate:
			canShoot = true

	# Smooth return to original position
	if isRecoiling:
		hand.transform.origin = hand.transform.origin.lerp(original_transform.origin, recoil_speed * delta)

		if hand.transform.origin.distance_to(original_transform.origin) < 0.001:
			hand.transform = original_transform
			isRecoiling = false

	if Input.is_action_just_pressed("reload"):
		reload()

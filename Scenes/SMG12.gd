extends Node

# Gun Modifiers
var maxAmmo : int = 28
var recoil_speed = 7.0
var bulletScene = preload("res://Bullet.tscn")
var recoil_distance := 0.1 # Recoil amount along local Z-axis
@export var fireRate: float = 0.1

# Internal State
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

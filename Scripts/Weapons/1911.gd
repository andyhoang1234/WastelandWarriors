extends Node

# Gun Modifiers
var maxAmmo: int = 12
var recoil_speed = 5.0
var bulletScene = preload("res://Scripts/Bullets/9mm.tscn")
var recoil_distance := 0.1
var recoil_rotation_up: float = 0.01
var recoil_rotation_side = -0.005
@export var fireRate: float = 0.1

# Internal State
@onready var shooter_peer_id = get_parent().get_parent().get_parent().player_peer_id
var active := false
var canShoot := true
var timeSinceLastShot := 0.0

# Ammo Management
var currentAmmo: int = 0          # Bullets currently loaded in magazine
var reserveAmmo: int = 100        # Bullets in total reserve
var isReloading: bool = false     # Prevents shooting while reloading
@export var reload_time: float = 1.5 # Seconds to reload

# Scene references
@onready var gun = $"1911"
@onready var bulletSpawn = $bulletSpawn
@onready var world = get_node("/root/testWorld")
var original_transform: Transform3D
var original_gun_z_rotation: float
var isRecoiling = false
@onready var weapon = $"." 
@onready var hand = get_parent()
@onready var cam = hand.get_parent()

func _ready():
	original_transform = hand.transform
	original_gun_z_rotation = gun.rotation.z
	reload() # start with full mag

func set_active(value: bool) -> void:
	active = value

func _physics_process(delta):
	if not active:
		return

	# Shooting
	if Input.is_action_just_pressed("shoot") and canShoot and not isReloading and currentAmmo > 0:
		shoot()

	# Cooldown timer
	if not canShoot:
		timeSinceLastShot += delta
		if timeSinceLastShot >= fireRate:
			canShoot = true

	# Smooth recoil recovery
	if isRecoiling:
		handle_recoil_recovery(delta)

	# Manual Reload
	if Input.is_action_just_pressed("reload") and not isReloading:
		start_reload()

func shoot():
	var bullet = bulletScene.instantiate()
	world.add_child(bullet)
	bullet.global_transform = bulletSpawn.global_transform
	bullet.scale = Vector3(0.01, 0.01, 0.01)
	bullet.shooter_peer_id = shooter_peer_id
	currentAmmo -= 1

	# Apply recoil
	var recoil_offset = hand.basis.z.normalized() * recoil_distance
	hand.transform.origin += recoil_offset
	gun.rotation.z -= recoil_rotation_up * 4
	if cam.rotation.x <= 1.52 and cam.rotation.x >= -1.52:
		cam.rotation.x += recoil_rotation_up
	cam.rotation.y = lerp(cam.rotation.y, randf_range(-recoil_rotation_side, recoil_rotation_side), 0.5)

	canShoot = false
	timeSinceLastShot = 0.0
	isRecoiling = true

func handle_recoil_recovery(delta):
	hand.transform.origin = hand.transform.origin.lerp(original_transform.origin, recoil_speed * delta)
	gun.rotation.z = lerp(gun.rotation.z, original_gun_z_rotation, recoil_speed * delta)
	hand.transform = hand.transform.interpolate_with(original_transform, recoil_speed * delta)
	if hand.transform.origin.distance_to(original_transform.origin) < 0.001:
		hand.transform = original_transform
		gun.rotation.z = original_gun_z_rotation
		isRecoiling = false

func start_reload():
	if currentAmmo == maxAmmo or reserveAmmo <= 0:
		return # no need to reload or no reserve ammo
	isReloading = true
	canShoot = false
	await get_tree().create_timer(reload_time).timeout
	reload()
	isReloading = false
	canShoot = true

func reload():
	var bullets_needed = maxAmmo - currentAmmo
	var bullets_to_load = min(bullets_needed, reserveAmmo)
	currentAmmo += bullets_to_load
	reserveAmmo -= bullets_to_load

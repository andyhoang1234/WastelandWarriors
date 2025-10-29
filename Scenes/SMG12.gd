extends Node

# Gun Modifiers
var maxAmmo: int = 28
var recoil_speed = 7.0
var bulletScene = preload("res://Scripts/Bullets/9mm.tscn")
var recoil_distance = 0.05
var recoil_rotation_up: float = 0.005
var recoil_rotation_side = 0.01
@export var fireRate: float = 0.05

# Internal State
@onready var shooter_peer_id = get_parent().get_parent().get_parent().player_peer_id
var active := false
var canShoot := true
var timeSinceLastShot := 0.0
var isRecoiling = false
var isReloading: bool = false

# Ammo Management
var currentAmmo: int = 0        # Bullets in current mag
var reserveAmmo: int = 150      # Total reserve ammo
@export var reload_time: float = 1.6 # Seconds to reload

# Scene references
@onready var bulletSpawn = $bulletSpawn
@onready var world = get_node("/root/testWorld")
var original_transform: Transform3D
@onready var weapon = $"."
@onready var hand = get_parent()
@onready var cam = hand.get_parent()

func _ready():
	original_transform = hand.transform
	reload() # start with full magazine

func set_active(value: bool) -> void:
	active = value

func _physics_process(delta):
	if not active:
		return

	# Shooting logic (auto fire)
	if Input.is_action_pressed("shoot") and canShoot and not isReloading and currentAmmo > 0:
		shoot()

	# Handle fire rate cooldown
	if not canShoot:
		timeSinceLastShot += delta
		if timeSinceLastShot >= fireRate:
			canShoot = true

	# Smooth recoil return
	if isRecoiling:
		handle_recoil_recovery(delta)

	# Reload trigger
	if Input.is_action_just_pressed("reload") and not isReloading:
		start_reload()

func shoot():
	var bullet = bulletScene.instantiate()
	world.add_child(bullet)
	bullet.global_transform = bulletSpawn.global_transform
	bullet.scale = Vector3(0.01, 0.01, 0.01)
	bullet.shooter_peer_id = shooter_peer_id
	currentAmmo -= 1

	# Apply recoil in local Z-axis
	var recoil_offset = hand.basis.z.normalized() * recoil_distance
	hand.transform.origin += recoil_offset

	if cam.rotation.x <= 1.52 and cam.rotation.x >= -1.52:
		cam.rotation.x += recoil_rotation_up

	cam.rotation.y = lerp(cam.rotation.y, randf_range(-recoil_rotation_side, recoil_rotation_side), 0.5)

	canShoot = false
	timeSinceLastShot = 0.0
	isRecoiling = true

func handle_recoil_recovery(delta):
	hand.transform.origin = hand.transform.origin.lerp(original_transform.origin, recoil_speed * delta)
	if hand.transform.origin.distance_to(original_transform.origin) < 0.001:
		hand.transform = original_transform
		isRecoiling = false

func start_reload():
	if currentAmmo == maxAmmo or reserveAmmo <= 0:
		return # Mag full or no spare ammo
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

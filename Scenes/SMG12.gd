extends Node

# Gun Modifiers
var maxAmmo : int = 40
var recoil_speed = 5.0
var bulletScene = preload("res://Scripts/Bullets/9mm.tscn")
var recoil_distance := 0.1 # Recoil amount along local Z-axis
var recoil_rotation_up : float = 0.01
var recoil_rotation_side = -0.01
@export var fireRate: float = 0.1

# Internal State
@onready var shooter_peer_id = get_parent().get_parent().get_parent().shooter_peer_id
var active := false
var canShoot := true
var timeSinceLastShot := 0.0
var ammo : int = 0              # bullets in the magazine
var reserveAmmo : int = 140     # total spare ammo carried

@onready var bulletSpawn = $bulletSpawn 
@onready var world = get_node("/root/testWorld")
var original_transform: Transform3D
var isRecoiling = false
@onready var weapon = $"." # The weapon node
@onready var hand = get_parent()
@onready var cam = hand.get_parent()

func _ready():
	original_transform = hand.transform
	reload_full_mag_on_start()

func reload_full_mag_on_start():
	# Fill the mag when the game starts, if we have enough reserve ammo
	var needed = maxAmmo - ammo
	var to_load = min(needed, reserveAmmo)
	ammo += to_load
	reserveAmmo -= to_load

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
		bullet.shooter_peer_id = shooter_peer_id
		ammo -= 1

		# Apply recoil in local Z-axis
		var recoil_offset = hand.basis.z.normalized() * recoil_distance
		hand.transform.origin += recoil_offset
		
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

	# Smooth return to original transform (position + rotation)
	if isRecoiling:
		hand.transform = hand.transform.interpolate_with(original_transform, recoil_speed * delta)
		if hand.transform.origin.distance_to(original_transform.origin) < 0.001:
			hand.transform = original_transform
			isRecoiling = false

	# Reload when pressing R
	if Input.is_action_just_pressed("reload"):
		reload()

func shoot():
	var bullet = bulletScene.instantiate()
	world.add_child(bullet)
	bullet.global_transform = bulletSpawn.global_transform
	bullet.scale = Vector3(0.01, 0.01, 0.01)
	ammo -= 1

	# Apply recoil
	var recoil_offset = hand.basis.z.normalized() * recoil_distance
	hand.transform.origin += recoil_offset

	if cam.rotation.x <= 1.52 and cam.rotation.x >= -1.52:
		cam.rotation.x += recoil_rotation_up

	cam.rotation.y += randf_range(-recoil_rotation_side, recoil_rotation_side)

	canShoot = false
	timeSinceLastShot = 0.0
	isRecoiling = true

func reload():
	# Can't reload if mag already full or no spare ammo
	if ammo >= maxAmmo or reserveAmmo <= 0:
		return
	
	var needed = maxAmmo - ammo              # how many bullets mag needs
	var to_load = min(needed, reserveAmmo)   # how many we can actually load

	ammo += to_load
	reserveAmmo -= to_load

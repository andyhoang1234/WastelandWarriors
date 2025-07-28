extends Node

var bulletScene = preload("res://Bullet.tscn")
@onready var bulletSpawn = $Smg12/bulletSpawn
@export var fireRate: float = 0.1  # Seconds between shots

var canShoot := true
var timeSinceLastShot := 0.0

var ammo : int = 5
var maxAmmo : int = 28

@onready var world = get_node("/root/testWorld")

var original_position
var recoil_offset = Vector3(0, 0, 0.2) # Adjust based on direction of the gun
var recoil_speed = 10.0
var isRecoiling = false
@onready var weapon = $"."

var camera_shake_magnitude := 0.04
var camera_shake_duration := 0.06
var camera_shake_timer := 0.0
var camera_original_transform: Transform3D
var is_shaking := false
var shake_time := 0.0  # Accumulator for smooth oscillation

@onready var camera = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	original_position = weapon.position
	camera_original_transform = camera.transform


func reload():
	ammo = maxAmmo
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
		#print(Global.dorrah)

		

	if Input.is_action_pressed("shoot") and canShoot and ammo > 0:
		var bullet = bulletScene.instantiate()
		world.add_child(bullet)
		bullet.global_transform = bulletSpawn.global_transform
		bullet.scale = Vector3(0.01, 0.01, 0.01)
		ammo -= 1

		# Recoil
		isRecoiling = true
		weapon.position = original_position + recoil_offset

		# Start smooth shake
		camera_shake_timer = camera_shake_duration
		shake_time = 0.0
		is_shaking = true
		canShoot = false
		timeSinceLastShot = 0.0
		isRecoiling = true
		weapon.position = original_position + recoil_offset
		
	elif not canShoot:
		timeSinceLastShot += delta
		if timeSinceLastShot >= fireRate:
			canShoot = true
			
		# Recoil return

	if isRecoiling:
	# Recoil weapon animation
		weapon.position = weapon.position.lerp(original_position, recoil_speed * delta)

	# End recoil phase
	if weapon.position.distance_to(original_position) < 0.001:
		weapon.position = original_position
		isRecoiling = false
	
	if Input.is_action_just_pressed("reload"):
		reload()

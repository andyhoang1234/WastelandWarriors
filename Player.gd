extends CharacterBody3D

signal health_changed(health_value)

@onready var camera = $Camera3D
@onready var anim_player = $AnimationPlayer
@onready var muzzle_flash = $Camera3D/Smg12/MuzzleFlash
@onready var raycast = $Camera3D/RayCast3D

var bulletScene = preload("res://Bullet.tscn")
@onready var bulletSpawn = $Camera3D/Hand/Llewlac/Smg12/bulletSpawn
@export var fireRate: float = 0.1  # Seconds between shots

@onready var world = get_node("/root/testWorld")

var health = 100
var canShoot := true
var timeSinceLastShot := 0.0

var camera_shake_magnitude := 0.04
var camera_shake_duration := 0.06
var camera_shake_timer := 0.0
var camera_original_transform: Transform3D
var is_shaking := false
var shake_time := 0.0  # Accumulator for smooth oscillation

var original_position
var recoil_offset = Vector3(0, 0, 0.2) # Adjust based on direction of the gun
var recoil_speed = 10.0
var isRecoiling = false
@onready var weapon = $Camera3D/Hand/Llewlac/Smg12

var SPEED = 5.0
var JUMP_VELOCITY

var ammo : int = 5
var maxAmmo : int = 28
var player_health = 100

@export var max_stamina: float = 100.0
@export var stamina_recovery_rate: float = 10.0 # per second
@export var stamina_drain_rate: float = 20.0    # per second (sprinting, etc.)

var current_stamina: float = max_stamina
var is_sprinting: bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 20.0

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func shoot():
	if ammo > 0:
		var bullet = bulletScene.instantiate()
		world.add_child(bullet)
		bullet.global_transform = bulletSpawn.global_transform
		bullet.scale = Vector3(0.1, 0.1, 0.1)
		ammo -= 1

		# Recoil
		isRecoiling = true
		weapon.position = original_position + recoil_offset

		# Start smooth shake
		camera_shake_timer = camera_shake_duration
		shake_time = 0.0
		is_shaking = true

func reload():
	ammo = maxAmmo
	print("Relaoded")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	original_position = weapon.position
	camera_original_transform = camera.transform

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		if Global.aiming == true:
			rotate_y(-event.relative.x * .0005)
			camera.rotate_x(-event.relative.y * .0005)
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
			
		else:
			rotate_y(-event.relative.x * .005)
			camera.rotate_x(-event.relative.y * .005)
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	handle_input()
	
	if is_shaking:
		shake_time += delta
		camera_shake_timer -= delta
		if camera_shake_timer > 0:
			var shake_x = sin(shake_time * 30.0) * camera_shake_magnitude
			var shake_y = sin(shake_time * 25.0 + PI / 2) * camera_shake_magnitude
			var shake_z = sin(shake_time * 20.0 + PI / 4) * camera_shake_magnitude * 0.5
			var offset = Vector3(shake_x, shake_y, shake_z)
			camera.transform.origin = camera_original_transform.origin + offset
		else:
			camera.transform.origin = camera_original_transform.origin
			is_shaking = false
	
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_pressed("shoot") and canShoot and ammo > 0:
		shoot()
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



	if is_sprinting and current_stamina > 0:
		current_stamina -= stamina_drain_rate * delta
		if current_stamina < 0:
			current_stamina = 0
			is_sprinting = false # force stop sprinting
	else:
		current_stamina += stamina_recovery_rate * delta
		if current_stamina > max_stamina:
			current_stamina = max_stamina
		
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if anim_player.current_animation == "shoot":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		anim_player.play("move")
	else:
		anim_player.play("idle")

	move_and_slide()


@rpc("call_local")
func play_shoot_effects():
	anim_player.stop()
	anim_player.play("shoot")
	muzzle_flash.restart()
	muzzle_flash.emitting = true
	
func handle_input():
	if Input.is_action_pressed("sprint") and current_stamina > 0:
		is_sprinting = true
	else:
		is_sprinting = false

@rpc("any_peer")
func receive_damage():
	health -= 1
	if health <= 0:
		health = 3
		position = Vector3.ZERO
	health_changed.emit(health)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		anim_player.play("idle")
		
		# Test comment

func restore_health_to_max():
	player_health = 100
	health_changed.emit(player_health)
	print("Player health restored to max!")


func reduce_health(amount):
	player_health -= 1
	health_changed.emit(health)
	if player_health < 0:
		get_tree().change_scene_to_file("res://lose.tscn")
			# The player dies. 
			# Go back to the main menu. This can be changed to any scene in the future.

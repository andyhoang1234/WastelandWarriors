@ -4,13 +4,10 @@ signal health_changed(health)

@onready var camera = $Camera3D
@onready var anim_player = $AnimationPlayer
@onready var muzzle_flash = $Camera3D/Smg12/MuzzleFlash
@onready var raycast = $Camera3D/RayCast3D
@onready var Lose = get_parent().get_node("CanvasLayer/Lose")

var bulletScene = preload("res://Bullet.tscn")
@onready var bulletSpawn = $Camera3D/Hand/Llewlac/Smg12/bulletSpawn
@export var fireRate: float = 0.1  # Seconds between shots


@onready var world = get_node("/root/testWorld")

@ -18,28 +15,10 @@ var hit_cooldown := 0.3  # cooldown time in seconds between hits
var time_since_last_hit := 0.0

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

var max_stamina = 100 
var stamina = 100
var stamina_drain = 20.0
@ -51,14 +30,10 @@ func _enter_tree():
	set_multiplayer_authority(str(name).to_int())


func reload():
	ammo = maxAmmo

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	original_position = weapon.position
	camera_original_transform = camera.transform
	

	Global.instakill = 1

func _unhandled_input(event):
@ -76,69 +51,7 @@ func _unhandled_input(event):
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	
	#print(Global.dorrah)
	
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


		
	if Input.is_action_pressed("player_run") and stamina > 0:
		SPEED = 10.0
		stamina -= stamina_drain * delta
@ -157,12 +70,12 @@ func _physics_process(delta):
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if anim_player.current_animation == "shoot":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		anim_player.play("move")
	else:
		anim_player.play("idle")
		
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()
	time_since_last_hit += delta
@ -181,20 +94,6 @@ func _physics_process(delta):
			reduce_health(15)
			time_since_last_hit = 0.0

@rpc("call_local")
func play_shoot_effects():
	anim_player.stop()
	anim_player.play("shoot")
	muzzle_flash.restart()
	muzzle_flash.emitting = true


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		anim_player.play("idle")
		
		# Test comment

func restore_health_to_max():
	health = 100
	health_changed.emit(health)

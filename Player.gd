extends CharacterBody3D

signal health_changed(health)

@onready var camera = $Camera3D
@onready var anim_player = $AnimationPlayer
@onready var raycast = $Camera3D/RayCast3D
@onready var Lose = get_parent().get_node("CanvasLayer/Lose")



@onready var world = get_node("/root/testWorld")

var hit_cooldown := 0.3  # cooldown time in seconds between hits
var time_since_last_hit := 0.0

var dorrah: int = 0

var health = 100

var SPEED = 5.0
var JUMP_VELOCITY

var max_stamina = 100 
var stamina = 100
var stamina_drain = 20.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 20.0

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())  # Make sure peer ID is int


func _ready():
	add_to_group("players")
	if not is_multiplayer_authority():
		rpc_id(1, "request_current_dorrah")  # Ask server for current value, assuming server peer 1
	# Your existing _ready content
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

	Global.instakill = 1
	
	if is_multiplayer_authority():
		var peer_id = get_multiplayer_authority()
		if not Global.dorrah_per_player.has(peer_id):
			Global.set_dorrah(peer_id, 0)
	else:
		# Ask server to sync current dorrah on join
		rpc_id(1, "request_add_dorrah", 0)  # Assuming peer 1 is server

func _unhandled_input(event):
	if not is_multiplayer_authority(): return


@rpc("any_peer", "call_remote")
func request_add_dorrah(amount: int):
	if not is_multiplayer_authority():
		return
	var peer_id = get_multiplayer_authority()
	Global.add_dorrah(peer_id, amount)
	rpc_id(peer_id, "sync_dorrah", Global.get_dorrah(peer_id))

@rpc("authority", "call_remote")
func request_current_dorrah():
	var peer_id = get_multiplayer_authority()
	print("Server received dorrah request from peer", peer_id)
	var current = Global.get_dorrah(peer_id)
	rpc_id(peer_id, "sync_dorrah", current)

@rpc("authority", "call_local")
func sync_dorrah(new_value: int):
	dorrah = new_value
	print("Client updated dorrah to:", new_value)
	world.update_dorrah_label(new_value)

func earn_dorrah(amount: int):
	rpc("request_add_dorrah", amount)

func _physics_process(delta):

	if Input.is_action_pressed("player_run") and stamina > 0:
		SPEED = 10.0
		stamina -= stamina_drain * delta
	else:
		SPEED = 5.0
		if stamina < max_stamina:
			stamina += stamina_drain * delta 
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

		
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()
	time_since_last_hit += delta
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
	
		if collider and time_since_last_hit >= hit_cooldown:
			if collider.name.begins_with("Enemy"):
				reduce_health(7)
				time_since_last_hit = 0.0
		elif collider.name.begins_with("Fast"):
			reduce_health(7)
			time_since_last_hit = 0.0
		elif collider.name.begins_with("Brute"):
			reduce_health(15)
			time_since_last_hit = 0.0

func restore_health_to_max():
	health = 100
	health_changed.emit(health)
	
func insta_kill():
	Global.instakill = 100
	
	var timer = Timer.new()
	timer.wait_time = 20
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_insta_kill_timeout"))
	add_child(timer)
	timer.start()

func _on_insta_kill_timeout():
	Global.instakill = 1

func reduce_health(amount):
	health -= amount
	world.update_health_bar(health)
	if health <= 0:
		Lose.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

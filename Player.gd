extends CharacterBody3D

signal health_changed(health)

@onready var camera = $Camera3D
@onready var anim_player = $AnimationPlayer
@onready var raycast = $Camera3D/RayCast3D
@onready var LOSE = $CanvasLayer/LOSE
@onready var TabMenu = $CanvasLayer/TabMenu
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/HealthBar
@onready var MainMenuMultiplayer = $CanvasLayer/MainMenuMultiplayer

@onready var world = get_node("/root/testWorld")

var hit_cooldown := 0.3
var time_since_last_hit := 0.0

var dorrah: int = 0
var health: int = 100

var SPEED = 5

@export var max_stamina: float = 100.0
@export var stamina: float = 100.0
@export var stamina_depletion_rate: float = 20.0
@export var sprint_speed: float = 20.0
@export var stamina_regen_rate: float = 10.0
@export var walk_speed: float = 5.0

var time_since_stopped_sprinting: float = 0.0
var stamina_regen_delay: float = 2.0  # seconds



var is_sprinting: bool 
var can_sprint: bool 

var gravity = 20.0

func _enter_tree():
	# Set multiplayer authority to this player's peer_id (assumes node name is peer_id as string)
	set_multiplayer_authority(get_tree().get_multiplayer().get_unique_id())

func _ready():
	stamina = max_stamina
	add_to_group("players")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if is_multiplayer_authority():
		var peer_id = get_multiplayer_authority()
		if not Global.dorrah_per_player.has(peer_id):
			Global.set_dorrah(peer_id, 15000) # Starting dorrah for player
		dorrah = Global.get_dorrah(peer_id)
	else:
		# Request current dorrah from server on join
		rpc_id(1, "request_current_dorrah")

	Global.instakill = 1

func _unhandled_input(event):
	if not is_multiplayer_authority():
		return

	if Input.is_action_pressed("tab"):
		TabMenu.show()
	else:
		TabMenu.hide()

# Server RPC: Player requests to add dorrah (e.g. from earning)
@rpc("authority", "call_remote")
func request_add_dorrah(amount: int) -> void:
	if not is_multiplayer_authority():
		return
	var peer_id = get_multiplayer_authority()
	Global.add_dorrah(peer_id, amount)
	# Sync updated dorrah back to this player via Global singleton RPC
	rpc_id(peer_id, "sync_dorrah", peer_id, Global.get_dorrah(peer_id))

# Server RPC: Player requests current dorrah (on join)
@rpc("authority", "call_remote")
func request_current_dorrah() -> void:
	var peer_id = get_multiplayer_authority()
	var current = Global.get_dorrah(peer_id)

	rpc_id(peer_id, "sync_dorrah", peer_id, current)

# Client RPC: Sync dorrah value from server
@rpc("any_peer", "call_remote")
func sync_dorrah(peer_id: int, new_value: int) -> void:
	if peer_id == get_multiplayer_authority():
		dorrah = new_value
		print("Client updated dorrah to:", new_value)
		if world:
			world.update_dorrah_label(new_value)

func earn_dorrah(amount: int) -> void:
	# Client requests server to add dorrah
	rpc_id(1, "request_add_dorrah", amount)

func _physics_process(delta: float) -> void:
	# Movement and stamina logic
	if Input.is_action_pressed("player_run") and stamina > 0:
		SPEED = 10.0
		stamina -= stamina_drain * delta
	else:
		SPEED = 5.0
		if stamina < max_stamina:
			stamina += stamina_drain * delta

	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction.length() > 0:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

		
	print(stamina)
	
	if Input.is_action_pressed("player_run") and stamina > 0:
		is_sprinting = true
		SPEED = sprint_speed
		stamina -= stamina_depletion_rate * delta
		time_since_stopped_sprinting = 0.0  # reset delay timer
	else:
		if is_sprinting:
			# just stopped sprinting
			time_since_stopped_sprinting = 0.0
			is_sprinting = false
			SPEED = walk_speed

# Increment timer if not sprinting
	if not is_sprinting:
		time_since_stopped_sprinting += delta

# Stamina regeneration after delay
	if not is_sprinting and time_since_stopped_sprinting >= stamina_regen_delay and stamina < max_stamina:
		stamina += stamina_regen_rate * delta


	
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
			if collider.name.begins_with("Enemy") or collider.name.begins_with("Fast") or collider.name.begins_with("Brute"):
				reduce_health(7 if not collider.name.begins_with("Brute") else 15)
				time_since_last_hit = 0.0

func reduce_health(amount: int) -> void:
	health -= amount
	update_health_bar(health)
	if health <= 0:
		die()
	set_process_input(false)

func die() -> void:
	LOSE.show()
	hud.hide()
	

func update_health_bar(health):
	health_bar.value = health

#MainMenuMultiplayer
func _on_remuse_multiplayer_pressed() -> void:
	MainMenuMultiplayer.hide()


func _on_quit_pressed() -> void:
	get_tree().quit()


#LOSE
func _on_timer_timeout() -> void:
	pass # Replace with function body.

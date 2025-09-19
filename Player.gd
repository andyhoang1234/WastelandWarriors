extends CharacterBody3D

signal health_changed(health)
var shooter_peer_id


const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()
@onready var Player = self
var player
var tracked = false

@onready var camera = $Camera3D
@onready var anim_player = $AnimationPlayer
@onready var raycast = $Camera3D/RayCast3D
@onready var LOSE = $CanvasLayer/LOSE
@onready var TabMenu = $CanvasLayer/TabMenu
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/HealthBar
@onready var MultiplayerMainMenu = $CanvasLayer/MultiplayerMainMenu
@onready var address_entry = get_node_or_null("CanvasLayer/MainMenu/Control/MarginContainer/VBoxContainer/AddressEntry")
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

var IpAddress

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
		
	else:
		# Request current dorrah from server on join
		rpc_id(1, "request_current_dorrah")

	Global.instakill = 1

	var upnp = UPNP.new()
	upnp.discover(2000, 2, "InternetGatewayDevice")
	IpAddress = upnp.query_external_address()
	
func _unhandled_input(event):
	if not is_multiplayer_authority():
		return

	if Input.is_action_pressed("tab"):
		TabMenu.show()
	else:
		TabMenu.hide()


func _physics_process(delta: float) -> void:
	print(dorrah)
	# Movement and stamina logic
	if Input.is_action_pressed("player_run") and stamina > 0:
		SPEED = 10.0
		stamina -= stamina_depletion_rate * delta
	else:
		SPEED = 5.0
		if stamina < max_stamina:
			stamina += stamina_depletion_rate * delta

	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction.length() > 0:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

		
	
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
	MultiplayerMainMenu.hide()


func _on_quit_pressed() -> void:
	get_tree().quit()


# Called when a new peer connects (server only)
func _on_peer_connected(id: int) -> void:
	Global.initialize_player(id)
	add_player(id)

# Called when a peer disconnects (server only)
func _on_peer_disconnected(id: int) -> void:
	remove_player(id)

#host
func _on_host_button_pressed() -> void:
	MultiplayerMainMenu.hide()
	
	var err = enet_peer.create_server(PORT)
	if err != OK:
		push_error("Failed to create server on port %d" % PORT)
		return
	
	multiplayer.multiplayer_peer = enet_peer
	
	# Connect signals for player join/leave
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	# Add the server player (peer ID 1)
	add_player(multiplayer.get_unique_id())
	
	# Optional: UPnP port mapping
	# upnp_setup()

# Join button pressed - connect to server


func _on_join_button_pressed() -> void:
	MultiplayerMainMenu.hide()
	
	var err = enet_peer.create_client(address_entry.text, PORT)
	if err != OK:
		push_error("Failed to connect to server at %s:%d" % [address_entry.text, PORT])
		return
	
	multiplayer.multiplayer_peer = enet_peer
	
	# You can connect to signals here if needed, e.g.:
	# multiplayer.peer_connected.connect(_on_peer_connected)
	# multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func add_player(peer_id: int) -> void:
	if get_node_or_null(str(peer_id)):
		return # Player already exists
	player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
	tracked = true
	print("Added player with peer ID:", peer_id)

func remove_player(peer_id: int) -> void:
	var player_node = get_node_or_null(str(peer_id))
	if player_node:
		player_node.queue_free()
		print("Removed player with peer ID:", peer_id)

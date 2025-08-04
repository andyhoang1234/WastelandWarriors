extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D

var SPEED = 6
var enemy_health = 10

@export var powerup_scene = preload("res://Scenes/randomDrop.tscn")
@export var min_dorrah_reward: int = 10
@export var max_dorrah_reward: int = 100

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	set_multiplayer_authority(1)  # Make sure the server is the authority
	enemy_health += Global.HMult

func update_target_location(target_location):
	nav_agent.set_target_position(target_location)

func _physics_process(_delta):
	if not is_multiplayer_authority(): return  # Only server moves enemy

	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	
	if current_location.distance_to(next_location) > 0.1:
		look_at(next_location)

	var new_velocity = (next_location - current_location).normalized() * SPEED
	velocity = new_velocity
	
	move_and_slide()

# Called by players to apply damage
@rpc("any_peer", "call_remote")
func take_damage(damage_amount: int, player_id: int):
	if not is_multiplayer_authority(): return  # Only server modifies health

	enemy_health -= damage_amount
	if enemy_health <= 0:
		_on_enemy_death(player_id)

func _on_enemy_death(killer_peer_id: int):
	var dorrah_reward = randi_range(min_dorrah_reward, max_dorrah_reward)
	
	# Add dorrah to the killer's total on the server
	Global.add_dorrah(killer_peer_id, dorrah_reward)
	rpc_id(killer_peer_id, "sync_dorrah", Global.get_dorrah(killer_peer_id))

	
	# Your existing code for powerup spawning, etc.
	
	rpc("networked_queue_free")  # Free the enemy on all clients
	print("Awarding dorrah:", dorrah_reward, "to peer:", killer_peer_id)
	rpc_id(killer_peer_id, "sync_dorrah", Global.get_dorrah(killer_peer_id))



@rpc("call_local")
func networked_queue_free():
	queue_free()

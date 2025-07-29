@ -1,15 +1,27 @@
extends Node3D

@onready var camera = get_parent()
const ADS_LERP = 15.0

@export var weapon_holder: Node3D
var weapons: Array[Node3D] = []
var current_weapon_index := 0

@onready var default_position = get_parent().position + Vector3(0.2, -1.55, -0.2)
@onready var ads_position = get_node('Llewlac/ads').position
#@onready var ads_position = get_child(currentgun).position
@onready var adsfov = 40.0
@onready var norfov = 90.0


func _ready():
	# Populate weapons array from children of the holder
	for child in weapon_holder.get_children():
		if child is Node3D:
			weapons.append(child)

	_equip_weapon(current_weapon_index)

func _process(delta):
	var camera = get_parent()
	
	# Update aiming state
	if Input.is_action_pressed("fire2"):
@ -23,3 +35,27 @@ func _process(delta):
	
	var target_position = ads_position if Global.aiming else default_position
	transform.origin = transform.origin.lerp(target_position, delta * ADS_LERP)
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_cycle_weapon(1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_cycle_weapon(-1)
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_Q: # or another key for cycling backward
			_cycle_weapon(-1)
		elif event.keycode == KEY_E: # or another key for cycling forward
			_cycle_weapon(1)

func _cycle_weapon(direction: int):
	weapons[current_weapon_index].visible = false
	current_weapon_index = (current_weapon_index + direction) % weapons.size()
	if current_weapon_index < 0:
		current_weapon_index = weapons.size() - 1
	_equip_weapon(current_weapon_index)

func _equip_weapon(index: int):
	for i in weapons.size():
		weapons[i].visible = i == index
	print("Equipped weapon:", weapons[index].name)

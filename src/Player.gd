extends KinematicBody

const GRAVITY = -24.8
const MAX_SPEED = 20
const MAX_SPRINT_SPEED = 30
const JUMP_SPEED = 18
const ACCEL = 4.5
const ACCEL_SPRINT = 18
const DEACCEL = 16
const MAX_SLOPE_ANGLE = 40
const WEAPON_NUMBER_TO_NAME = {0:"UNARMED", 1:"KNIFE", 2:"PISTOL", 3:"RIFLE"}
const WEAPON_NAME_TO_NUMBER = {"UNARMED":0, "KNIFE":1, "PISTOL":2, "RIFLE":3}

var vel = Vector3()
var dir = Vector3()
var camera
var rotation_helper
var mouse_sensitivity = 0.05
var is_sprinting = false
var flashlight
var animation_manager
var current_weapon_name = "UNARMED"
var weapons = {"UNARMED":null, "KNIFE":null, "PISTOl":null, "RIFLE":null}
var is_changing_weapon : bool = false
var changing_weapon_name = "UNARMED"
var health = 100
var UI_status_label

func _ready():
	camera = $RotationHelper/Camera
	rotation_helper = $RotationHelper
	
	animation_manager = $RotationHelper/Model/AnimationPlayer
	animation_manager.callback_function = funcref(self, "fire_bullet")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	weapons["KNIFE"] = $RotationHelper/GunFirePoints/KnifePoint
	weapons["PISTOL"] = $RotationHelper/GunFirePoints/PistolPoint
	weapons["RIFLE"] = $RotationHelper/GunFirePoints/RiflePoint
	
	var gun_aim_point_position = $RotationHelper/GunAimPoint.global_transform.origin
	
	for weapon in weapons:
		var weapon_node = weapons[weapon]
		if weapon_node != null:
			weapon_node.player_node = self
			weapon_node.look_at(gun_aim_point_position, Vector3(0, 1, 0))
			weapon_node.rotate_object_local(Vector3(0, 1, 0), deg2rad(180))
	current_weapon_name = "UNARMED"
	changing_weapon_name = "UNARMED"
	UI_status_label = $HUD/Panel/Gunlabel
	flashlight = $RotationHelper/Flashlight


func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	process_changing_weapons(delta)


func process_input(delta):
	dir = Vector3()
	var cam_xform = camera.get_global_transform()
	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x

	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = JUMP_SPEED
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_pressed("movement_sprint"):
		is_sprinting = true
	else:
		is_sprinting = false
	if Input.is_action_just_pressed("flashlight"):
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()
	
	var weapon_change_number = WEAPON_NAME_TO_NUMBER[current_weapon_name]
	if Input.is_key_pressed(KEY_1):
		weapon_change_number = 0
	if Input.is_key_pressed(KEY_2):
		weapon_change_number = 1
	if Input.is_key_pressed(KEY_3):
		weapon_change_number = 2
	if Input.is_key_pressed(KEY_4):
		weapon_change_number = 3
	
	if Input.is_action_just_pressed("shift_weapon_positive"):
		weapon_change_number += 1
		print(weapon_change_number)
	if Input.is_action_just_pressed("shift_weapon_negative"):
		weapon_change_number -= 1
		print(weapon_change_number)
	weapon_change_number = clamp(weapon_change_number, 0, WEAPON_NUMBER_TO_NAME.size() - 1)
	if is_changing_weapon == false:
		if WEAPON_NUMBER_TO_NAME[weapon_change_number] != current_weapon_name:
			changing_weapon_name = WEAPON_NUMBER_TO_NAME[weapon_change_number]
			is_changing_weapon = true
	
	if Input.is_action_pressed("fire"):
		if is_changing_weapon == false:
			var current_weapon = weapons[current_weapon_name]
			if current_weapon != null:
				if animation_manager.current_state == current_weapon.IDLE_ANIMATION_NAME:
					animation_manager.set_animation(current_weapon.FIRE_ANIMATION_NAME)


func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()
	vel.y += delta * GRAVITY
	var hvel = vel
	hvel.y = 0
	var target = dir
	
	if is_sprinting:
		target *= MAX_SPRINT_SPEED
	else:
		target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		if is_sprinting:
			accel = ACCEL_SPRINT
		else:
			accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))


func process_changing_weapons(delta):
	if is_changing_weapon == true:
		var weapon_unequipped = false
		var current_weapon = weapons[current_weapon_name]
		if current_weapon == null:
			weapon_unequipped = true
		else:
			if current_weapon.is_weapon_enabled == true:
				weapon_unequipped = current_weapon.unequip_weapon()
			else:
				weapon_unequipped = true
		if weapon_unequipped == true:
			var weapon_equipped = false
			var weapon_to_equip = weapons[changing_weapon_name]
			if weapon_to_equip == null:
				weapon_equipped = true
			else:
				if weapon_to_equip.is_weapon_enabled == false:
					weapon_equipped = weapon_to_equip.equip_weapon()
				else:
					weapon_equipped = true
			if weapon_equipped == true:
				is_changing_weapon = false
				current_weapon_name = changing_weapon_name
				changing_weapon_name = ""


func fire_bullet():
	if is_changing_weapon == true:
		return
	weapons[current_weapon_name].fire_weapon()


func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * mouse_sensitivity))
		self.rotate_y(deg2rad(event.relative.x * mouse_sensitivity * -1))
		var camera_rotation = rotation_helper.rotation_degrees
		camera_rotation.x = clamp(camera_rotation.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rotation

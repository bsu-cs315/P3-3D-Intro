extends KinematicBody

const GRAVITY : float = -24.8
const MAX_SPEED : int = 20
const MAX_SPRINT_SPEED : int = 30
const JUMP_SPEED : int = 18
const ACCEL : float = 4.5
const ACCEL_SPRINT : int = 18
const DEACCEL : int = 16
const MAX_SLOPE_ANGLE : int = 40

var vel : Vector3 = Vector3()
var dir : Vector3 = Vector3()
var camera
var rotation_helper
var mouse_sensitivity : float = 0.05
var is_sprinting : bool = false
var flashlight

func _ready() -> void:
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper
	flashlight = $Rotation_Helper/Flashlight


func _physics_process(delta : float) -> void:
	process_input(delta)
	process_movement(delta)


func process_input(delta : float) -> void:
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


func process_movement(delta : float) -> void:
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
	
	
func _input(event) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * mouse_sensitivity))
		self.rotate_y(deg2rad(event.relative.x * mouse_sensitivity * -1))
		var camera_rotation = rotation_helper.rotation_degrees
		camera_rotation.x = clamp(camera_rotation.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rotation

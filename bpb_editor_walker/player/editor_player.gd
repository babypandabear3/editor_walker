@tool
class_name Editor_Player
extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var editor_walker_active := false
var plugin_camera

@onready var axis_y = $camera_root/axis_y
@onready var axis_x = $camera_root/axis_y/axis_x

var camera_sensitivity := 30.0 #THIS SHOULD BE READ FROM GAME SETTING
var camera_multiply = 0.0001
var camera_x_limit_high := 60.0
var camera_x_limit_low := -89.0

var motion = Vector2.ZERO
var input_dir = Vector2.ZERO

func _physics_process(delta):
	if not editor_walker_active:
		return
		
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	input_dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_D):
		input_dir.x += 1
	if Input.is_key_pressed(KEY_W):
		input_dir.y -= 1
	if Input.is_key_pressed(KEY_S):
		input_dir.y += 1
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var dir_x = axis_y.global_transform.basis.x
	var dir_z = axis_y.global_transform.basis.z
	
	#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = ((dir_x * input_dir.x) + (dir_z * input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	#MOUSE LOOK
	var camera_pos = $camera_root/axis_y/axis_x/camera_pos
	motion = Input.get_last_mouse_velocity() * delta
	axis_y.rotate_y(-motion.x * camera_sensitivity * camera_multiply)
	axis_x.rotate_x(-motion.y * camera_sensitivity * camera_multiply)
	axis_x.rotation_degrees.x = clampf(axis_x.rotation_degrees.x, camera_x_limit_low, camera_x_limit_high)
	
	plugin_camera.global_transform = camera_pos.global_transform
	call_deferred("send_camera_transform_to_plugin", plugin_camera, camera_pos)
	

func send_camera_transform_to_plugin(plugin_camera, camera_pos):
	#SEND TRANSFORM TO VIEWPORT CAMERA
	plugin_camera.global_transform = plugin_camera.global_transform.interpolate_with(camera_pos.global_transform, 0.5)
	

extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 5.5
const STEP_VELOCITY = 2.0

@onready var joyTrans = $JoystickTrans
@onready var joyRot = $JoystickRot

signal player_hit

func _physics_process(delta: float) -> void:
	
	#### GRAVITY
	if not is_on_floor():
		velocity += get_gravity() * delta

	#### JUMP
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	#### KEYBOARD
	# Get the input direction and handle the movement/deceleration.
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input.x, 0, input.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if is_on_floor(): velocity.y = STEP_VELOCITY
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	#### JOYSTICKS	
	input = joyRot.get_value()
	if input:
		#%Camera3D.rotation_degrees.y -= input.x * SPEED/2
		rotation_degrees.y -= input.x * SPEED / 2
		%Camera3D.rotation_degrees.x -= input.y * SPEED/2
		%Camera3D.rotation_degrees.x = clamp(%Camera3D.rotation_degrees.x, -40, +40)

	input = joyTrans.get_value()
	if input:
		direction = (transform.basis * Vector3(input.x, 0, input.y)).normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if is_on_floor(): velocity.y = STEP_VELOCITY
		
	move_and_slide()

	#if Input.is_action_pressed("shoot") and %Timer.is_stopped():
	#	shoot_bullet()

#TODO: Shot : real effect = raycast? && show riffle working
#TODO: Jump button : to activate jump

func hit():
	emit_signal("player_hit")

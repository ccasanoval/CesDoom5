extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 5.5
const STEP_VELOCITY = 2.0

const FIRE_RAY_LENGTH = 9000
const FIRERATE = 0.09
var fireCooldown := FIRERATE

var hasSetTheBomb = false

@onready var joyTrans = $JoystickTrans
@onready var joyRot = $JoystickRot
@onready var jumpButton = $JumpButton
@onready var muzzleFlash = $Camera3D/AKM/MuzzleFlash
@onready var flash = $Camera3D/AKM/Flash

var health = 100
signal player_hit

#TODO: Ride motorcycle or car... Touch -> Ride -> Change mode, change view...

#----------------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	
	#### GRAVITY
	if not is_on_floor():
		velocity += get_gravity() * delta

	#### JUMP
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	#### FIRE
	fireCooldown += delta
	if fireCooldown > FIRERATE*8/10:
		flash.visible = false
		muzzleFlash.visible = false
	if Input.is_action_pressed("fire") and fireCooldown > FIRERATE:
		fire()
		
	#### TOUCH
	var rayTouch = $Camera3D/RayCastTouch
	if rayTouch.is_colliding():
		var collider = rayTouch.get_collider()
		if collider != null and collider.is_in_group("Teleporter"):
			collider.teleport()
		if collider != null and collider.is_in_group("Activate"):
			#TODO: Change weapon by hand to let the user touch and activate with a menu?...
			collider.activate()
	
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
		%Camera3D.rotation_degrees.x -= input.y * SPEED/5
		%Camera3D.rotation_degrees.x = clamp(%Camera3D.rotation_degrees.x, -40, +40)

	input = joyTrans.get_value()
	if input:
		direction = (transform.basis * Vector3(input.x, 0, input.y)).normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if is_on_floor(): velocity.y = STEP_VELOCITY
		
	move_and_slide()

#----------------------------------------------------------------------------------------
#Fire shot animation: https://www.youtube.com/watch?v=ERFCutI6mqc
#TODO: Discount number of available bullets
#TODO: Add magazin picking to get more available bullets
func fire():
	fireCooldown = 0
	flash.visible = true
	muzzleFlash.visible = true
	var ray = $Camera3D/RayCast3D
	if ray.is_colliding():
		var collider = ray.get_collider()
		#if collider is CharacterBody3D: collider.hit()
		if collider != null and collider.is_in_group("Mob"): collider.hit()
		print("Collided at ", collider)

#----------------------------------------------------------------------------------------
#TODO: Detect contact with mob bullets and have pain, discount health and if < 0, die
func hit():
	emit_signal("player_hit")

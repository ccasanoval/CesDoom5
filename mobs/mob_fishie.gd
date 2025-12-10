extends CharacterBody3D

#signal player_hit
var player = null
@export var player_path: NodePath
@onready var nav_agent = %NavigationAgent3D
@onready var anim_tree = %AnimationTree
@onready var timer = $Timer
var anim_state_machine

var health = 100

const SPEED = 2.0
const RANGE_PLAYER_AT_SIGHT = 10
const RANGE_PLAYER_NOT_AT_SIGHT = 20
const RANGE_PLAYER_IS_NEXT = 1.75

func _ready() -> void:
	player = get_node(player_path)
	anim_state_machine = anim_tree.get("parameters/playback")
	
func _process(delta: float) -> void:
	velocity = Vector3.ZERO
	
	#### DIYING
	if health < 5:
		rotate_object_local(Vector3.LEFT, delta)
		if rotation.x < -1.5: queue_free()
		#TODO: Add points to player?
		return
	
	#### GRAVITY
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	### ANIMATIONS	
	var next = global_position.distance_to(player.global_position) < RANGE_PLAYER_IS_NEXT
	var sight = global_position.distance_to(player.global_position) < RANGE_PLAYER_AT_SIGHT
	var not_sight = global_position.distance_to(player.global_position) > RANGE_PLAYER_NOT_AT_SIGHT
	if !timer.is_stopped():
		next = false
		sight = false
		not_sight = true
	anim_tree.set("parameters/conditions/player_at_sight", sight)
	anim_tree.set("parameters/conditions/player_is_next", next)
	anim_tree.set("parameters/conditions/player_not_at_sight", not_sight)

	match anim_state_machine.get_current_node():
		"Idle_g":
			#### DO NOTHING
			pass
		"Run_Aim_g":
			#### SEARCH AND DESTROY
			nav_agent.set_target_position(player.global_position)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_position).normalized() * SPEED
			look_at(next_nav_point, Vector3.UP)
			#TODO: Shoot
		"Throw_g":
			#### HIT
			look_at(player.global_position, Vector3.UP)
			await get_tree().create_timer(0.3).timeout
			if global_position.distance_to(player.global_position) < RANGE_PLAYER_IS_NEXT:
				player.hit()
	
	move_and_slide()

func hit():
	print("Awww, I get hit")
	$OmniLight3D.visible = true
	$OmniLight3D2.visible = true
	timer.connect("timeout", _on_timer_timeout)
	timer.start(.5)
	health -= 5
	
func _on_timer_timeout():
	print("Ok, I'm better now. Health = ", health)
	$OmniLight3D.visible = false
	$OmniLight3D2.visible = false
	pass
	

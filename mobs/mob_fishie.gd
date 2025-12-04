extends CharacterBody3D

var player = null
@export var player_path: NodePath
@onready var nav_agent = %NavigationAgent3D
@onready var anim_tree = %AnimationTree
var anim_state_machine

const SPEED = 2.0
const RANGE_PLAYER_AT_SIGHT = 10
const RANGE_PLAYER_IS_NEXT = 3

func _ready() -> void:
	player = get_node(player_path)
	anim_state_machine = anim_tree.get("parameters/playback")
	
func _process(delta: float) -> void:
	velocity = Vector3.ZERO
	
	#### GRAVITY
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	### ANIMATIONS	
	var next = global_position.distance_to(player.global_position) < RANGE_PLAYER_IS_NEXT
	var sight = global_position.distance_to(player.global_position) < RANGE_PLAYER_AT_SIGHT
	anim_tree.set("parameters/conditions/player_at_sight", sight)
	anim_tree.set("parameters/conditions/player_is_next", next)
	anim_tree.set("parameters/conditions/player_not_at_sight", !sight)

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
	
	move_and_slide()

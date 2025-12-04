extends CharacterBody3D

var player = null
@export var player_path: NodePath
@onready var nav_agent = %NavigationAgent3D

const SPEED = 4.0
const JUMP_VELOCITY = 4.5

func _ready() -> void:
	player = get_node(player_path)
	
func _process(delta: float) -> void:
	velocity = Vector3.ZERO
	
	#### GRAVITY
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#### SEARCH AND DESTROY
	nav_agent.set_target_position(player.global_transform.origin)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
	
	move_and_slide()

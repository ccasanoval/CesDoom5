extends CharacterBody3D

#signal player_hit
var player = null
@export var player_path: NodePath
@onready var nav_agent = %NavigationAgent3D
@onready var anim_tree = %AnimationTree
@onready var timerHit = $TimerHit
@onready var timerFire = $TimerFire
@onready var ray = $RayCast3D
var anim_state_machine
var is_firing = false

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
	if !timerHit.is_stopped():
		next = false
		sight = false
		not_sight = true

	var is_firing_now = false
	if !next and !is_firing and ray.is_colliding():
		var collider = ray.get_collider()
		if collider != null and collider.is_in_group("Player"):
			#TODO: Look ant player
			is_firing_now = true
			fire()

	anim_tree.set("parameters/conditions/at_fire_range", is_firing_now)
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
				player.hit(delta)
	
	move_and_slide()

func hit():
	print("Awww, I get hit")
	$OmniLight3D.visible = true
	$OmniLight3D2.visible = true
	timerHit.connect("timeout", _on_timer_hit_timeout)
	timerHit.start(.5)
	health -= 5
	
func _on_timer_hit_timeout():
	print("Ok, I'm better now. Health = ", health)
	$OmniLight3D.visible = false
	$OmniLight3D2.visible = false

func fire():
	print("Fire!!")
	is_firing = true
	timerFire.connect("timeout", _on_timer_fire_timeout)
	timerFire.start(5)
	# Create bullet
	await get_tree().create_timer(0.3).timeout
	const BULLET_3D = preload("res://mobs/bullet/bullet_3d.tscn")
	var new_bullet = BULLET_3D.instantiate()
	$FireMarker.add_child(new_bullet)
	new_bullet.global_transform = $FireMarker.global_transform
		
func _on_timer_fire_timeout():
	print("Fire ready again")
	is_firing = false
	anim_tree.set("parameters/conditions/at_fire_range", false)

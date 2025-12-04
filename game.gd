extends Node3D

#RESOURCES:
#----------

#3D Objects
#https://www.fab.com/listings/1353e155-41de-4f7f-a6a3-a4d6f72b115a

#3D Viewer
#https://gltf-viewer.donmccurdy.com/

#Textures
#https://ambientcg.com/list?category=NightSkyHDRISubstance&type=substance&sort=popular

#Plugins
#https://github.com/Saulo-de-Souza/VirtualJoystick

#Tutorial
#https://www.gdquest.com/library/first_3d_game_godot4_arena_fps/#creating-the-level

@onready var hit_rect = $UI/HitRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_player_hit() -> void:
	hit_rect.visible = true
	await get_tree().create_timer(0.3).timeout
	hit_rect.visible = false

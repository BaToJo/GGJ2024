
extends Node2D

@onready var camera = get_node("Camera")
@onready var character = get_node("Link")
@onready var mouse_position = character.get_global_mouse_position()
@onready var projectile = %projectile




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

	

	




# ___________________________________________________________________________________________ Camera


# Handle camera behaviour and respond to camera related user input
func update_camera():
	character.look_at(mouse_position)#
	var viewport_size: Vector2 = get_viewport().size
	var mouse_offset = (get_viewport().get_mouse_position() - viewport_size / 2)
	camera.position = character.position + lerp(Vector2(), mouse_offset.normalized() * 500, (((mouse_offset.length()+1)*(mouse_offset.length()+1))-1) / 2000000)




# Consider trying this cool 2D FoV effect: https://www.reddit.com/r/godot/comments/sgdm1y/comment/huvtulb/

# ___________________________________________________________________________ (end of Camera)

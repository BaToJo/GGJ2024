extends CharacterBody2D

const SPEED = 100.0
@export var Bullet: PackedScene
@export var Is_Player: bool = false
@onready var camera = $"../Camera"
@onready var animated_sprite = $"../AnimatedSprite2D"
@onready var eye_left = $"../AnimatedSprite2D/Eye Left/Pupil"
@onready var eye_right = $"../AnimatedSprite2D/Eye Right/Pupil"
@onready var nav = $"../AnimatedSprite2D/Nav" as NavigationAgent2D
@export var fire_rate = 0.2
var eye_left_start_position: Vector2
var eye_right_start_position: Vector2
var nav_target_pos: Vector2 = $".".get_global_mouse_position()

var actual_rate = 0.2
var timer = 0

var power = false
var power_timer = 0

@onready var absolute_parent = get_parent()


var die: bool = false

# Handle camera behaviour and respond to camera related user input
func update_camera():
	var viewport_size: Vector2 = get_viewport().size
	var mouse_offset = (get_viewport().get_mouse_position() - viewport_size / 2)
	camera.position = animated_sprite.position + lerp(Vector2(), mouse_offset.normalized() * 500, (((mouse_offset.length()+1)*(mouse_offset.length()+1))-1) / (1500000 * camera.zoom.length()))



func _ready():
	# Camera.set("position", Vector2(100, 0))
	eye_left_start_position = $"../AnimatedSprite2D/Eye Left".position
	eye_right_start_position = $"../AnimatedSprite2D/Eye Right".position

func _physics_process(delta):
	timer += delta

	update_camera()

	if power == true:
		power_timer += delta
		actual_rate = fire_rate / 2
		if power_timer >= 10:
			power = false
	else:
		actual_rate = fire_rate
		power_timer = 0

	# Eye pupils follow mouse cursor
	if animated_sprite.flip_h:
		$"../AnimatedSprite2D/Eye Left".position.x = -eye_left_start_position.x
		$"../AnimatedSprite2D/Eye Right".position.x = -eye_right_start_position.x
	else:
		$"../AnimatedSprite2D/Eye Left".position.x = eye_left_start_position.x
		$"../AnimatedSprite2D/Eye Right".position.x = eye_right_start_position.x

	var offset_left = $".".get_global_mouse_position() - ($"../AnimatedSprite2D/Eye Left".position + $"../AnimatedSprite2D".position)
	var offset_right = $".".get_global_mouse_position() - ($"../AnimatedSprite2D/Eye Right".position + $"../AnimatedSprite2D".position)
	eye_left.position = offset_left / (8.0 * sqrt(offset_left.length()))
	eye_right.position = offset_right / (8.0 * sqrt(offset_right.length()))


	var direction_x = 0.0
	var direction_y = 0.0
	if Is_Player:
		direction_x = Input.get_axis("Left", "Right")
		direction_y = Input.get_axis("Up", "Down")
	else:
		# We're an NPC, so navigate towards the mouse cursor.
		var vector_to_target_angle = (nav.get_next_path_position() - $".".global_position).normalized()
		var vector_to_target_distance = (get_global_mouse_position() - $".".global_position).length() / 100
		if vector_to_target_distance > 1:
			vector_to_target_distance = 1
		var vector_to_target = vector_to_target_angle * vector_to_target_distance


		# var vector_to_target = nav.get_next_path_position() - position
		direction_x = vector_to_target.x
		direction_y = vector_to_target.y
	velocity.x = 0
	velocity.y = 0


	if die == true:
		if Input.get_action_raw_strength("Respawn"):
			Respawn()
		return

	#
	#if Input.get_action_raw_strength("Shoot") && timer >= actual_rate:
		#var temp = Bullet.instantiate()
		#add_sibling(temp)
		#temp.global_position = get_node("BulletSpawn").get("global_position")
#
		#temp.set("area_direction", (get_global_mouse_position() - self.global_position).normalized())
#
		#Camera.set("offset", Vector2(randf_range(-4, 4), randf_range(-4, 4)))
		#timer = 0


	# else:
		# Camera.set("offset", Vector2(0, 0))

	if direction_x:
		velocity.x = direction_x * SPEED
	if direction_y:
		velocity.y = direction_y * SPEED


	self.look_at(get_global_mouse_position())

	if velocity.length() == 0:
		animated_sprite.stop()
	else:
		animated_sprite.play()
		animated_sprite.speed_scale = velocity.length() * 0.015
	if velocity.x < 0:
		animated_sprite.flip_h = true
	if velocity.x > 0:
		animated_sprite.flip_h = false

	# velocity /= velocity.length()

	move_and_slide()


func Make_nav_path() -> void:
	var temp = get_global_mouse_position()
	nav.target_position = get_global_mouse_position()


func Die():
	get_node("Explosive").set_emitting(true)
	get_node("Explosive/Sound").play()
	self.get_node("MeshInstance2D").set("visible", false)

	# Camera.set("position", Vector2(0, 0))
	die = true

	await get_tree().create_timer(1.5).timeout

	position = Vector2(383,397)

	$"../Retry".show()


func Respawn():
	get_tree().reload_current_scene()


func _input(event):
	if event.is_action_pressed("zoom_in"):
		camera.zoom *= 1.1
	if event.is_action_pressed("zoom_out"):
		camera.zoom /= 1.1


func _on_nav_timer_timeout() -> void:
	Make_nav_path()

extends CharacterBody2D

const SPEED = 300.0
@export var Bullet: PackedScene
@onready var Camera = get_node("Camera2D")
@export var fire_rate = 0.2
var actual_rate = 0.2
var timer = 0

var power = false
var power_timer = 0

@onready var absolute_parent = get_parent()

var die: bool = false

func _ready():

	Camera.set("position", Vector2(100, 0))

func _physics_process(delta):
	timer += delta

	if power == true:
		power_timer += delta
		actual_rate = fire_rate / 2
		if power_timer >= 10:
			power = false
	else:
		actual_rate = fire_rate
		power_timer = 0
	
	
	var direction_x = Input.get_axis("Left", "Right")
	var direction_y = Input.get_axis("Up", "Down")
	velocity.x = 0
	velocity.y = 0
	
	 
	if die == true:
		if Input.get_action_raw_strength("Respawn"):
			Respawn()
		return
	

	if Input.get_action_raw_strength("Shoot") && timer >= actual_rate:
		var temp = Bullet.instantiate()
		add_sibling(temp)
		temp.global_position = get_node("BulletSpawn").get("global_position")
		
		temp.set("area_direction", (get_global_mouse_position() - self.global_position).normalized())
		
		Camera.set("offset", Vector2(randf_range(-4, 4), randf_range(-4, 4)))
		timer = 0
		
		
	else:
		Camera.set("offset", Vector2(0, 0))
	
	if direction_x:
		velocity.x = direction_x * SPEED
	if direction_y:
		velocity.y = direction_y * SPEED
		

	self.look_at(get_global_mouse_position())
	
	move_and_slide()


func Die():
	get_node("Explosive").set_emitting(true)
	get_node("Explosive/Sound").play()
	self.get_node("MeshInstance2D").set("visible", false)

	Camera.set("position", Vector2(0, 0))
	die = true
	
	await get_tree().create_timer(1.5).timeout
	
	position = Vector2(383,397)

	$"../Retry".show()
	
func Respawn():
	get_tree().reload_current_scene()

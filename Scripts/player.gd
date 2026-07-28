extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var sensitivity = 0.003
var attack_cooldown = false
var gold = 0
var hp = 50
var max_hp = 50

@onready var camera = $Camera3D
@onready var animationPlayer = $AnimationPlayer
@onready var attackCooldown = $attackCooldown
@onready var hpBar = $HUD/HpBar
@onready var goldlabel = $HUD/Gold
@onready var attackHitbox = $AttackHitbox

func _ready() -> void:
	hpBar.max_value = 50
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	add_to_group("player")

func take_damage(amount: int) -> void:
	hp = clamp(hp - amount, 0, max_hp)

func attack():
	if Input.is_action_just_pressed("attack") and attack_cooldown == false:
		animationPlayer.play("swordSwing")
		attack_cooldown = true
		attackCooldown.start()
		deal_attack_damage()

func deal_attack_damage() -> void:
	for body in attackHitbox.get_overlapping_bodies():
		if body.is_in_group("enemy") and body.has_method("take_damage"):
			body.take_damage(15)

func update_HUD():
	hpBar.value = hp
	goldlabel.text = str(gold)
	

func _process(delta):
	attack()
	update_HUD()
	if Input.is_action_just_pressed("escaped"):
		get_tree().quit()
		

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp (camera.rotation.x, deg_to_rad(-60), deg_to_rad(70))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _on_attack_cooldown_timeout() -> void:
	attack_cooldown = false # Replace with function body.

extends CharacterBody3D

enum States {attack, idle, chase, die}

var state = States.idle
var hp = 15
var speed = 2.0
var damage = 5
var target: Node3D = null
var can_attack = true

@onready var animation_player = $GobelinExport/AnimationPlayer
@onready var attack_cooldown_timer = $attackCooldownTimer


func _ready() -> void:
	add_to_group("enemy")


func _process(delta: float) -> void:
	behavior()


func _physics_process(delta: float) -> void:
	if state == States.chase and target:
		var direction = target.global_position - global_position
		direction.y = 0
		if direction.length() > 0.01:
			direction = direction.normalized()
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			look_at(global_position + direction, Vector3.UP)
			rotate_object_local(Vector3.UP, PI)
	else:
		velocity.x = 0
		velocity.z = 0

	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()


func behavior():
	match state:
		States.idle:
			play_animation("Idle")
		States.chase:
			play_animation("Walk")
		States.attack:
			play_animation("Punch")
			try_attack()
		States.die:
			play_animation("Die")


func play_animation(anim_name: String) -> void:
	if animation_player.current_animation != anim_name:
		animation_player.play(anim_name)


func try_attack() -> void:
	if can_attack and target and target.has_method("take_damage"):
		can_attack = false
		target.take_damage(damage)
		attack_cooldown_timer.start()


func _on_attack_cooldown_timer_timeout() -> void:
	can_attack = true


func take_damage(amount: int) -> void:
	if state == States.die:
		return
	hp -= amount
	if hp <= 0:
		hp = 0
		state = States.die
		target = null
		await get_tree().create_timer(1.0).timeout
		queue_free()


func _on_chase_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		target = body
		if state != States.attack and state != States.die:
			state = States.chase


func _on_chase_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		if state != States.die:
			state = States.idle
		target = null


func _on_attack_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		target = body
		if state != States.die:
			state = States.attack


func _on_attack_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		if state != States.die:
			state = States.chase

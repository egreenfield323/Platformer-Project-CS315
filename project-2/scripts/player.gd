extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -300.0

@export var health = 5

@onready var anim_tree = $AnimationTree

var facing = 1

@onready var has_died = $"..".has_died
@onready var has_glasses = $"..".has_glasses

func _physics_process(delta: float) -> void:
	if !has_died:
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			anim_tree['parameters/conditions/jump'] = true
			$"Sounds/bg/sfx/jump".playing = true
		else:
			anim_tree['parameters/conditions/jump'] = false

		var direction := Input.get_axis("left", "right")

		#facing left
		if direction < 0 and facing == 1:
			self.scale.x *= -1
			facing = -1
			
		#facing right
		if direction > 0 and facing == -1:
			self.scale.x *= -1
			facing = 1
		
		if direction:
			velocity.x = direction * SPEED
			if is_on_floor():
				if !$"Sounds/bg/sfx/walk".playing:
					$"Sounds/bg/sfx/walk".playing = true
				anim_tree['parameters/conditions/run'] = true
				anim_tree['parameters/conditions/idle'] = false
			else:
				if $"Sounds/bg/sfx/walk".playing:
					$"Sounds/bg/sfx/walk".playing = false
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if is_on_floor():
				if $"Sounds/bg/sfx/walk".playing:
					$"Sounds/bg/sfx/walk".playing = false
				anim_tree['parameters/conditions/run'] = false
				anim_tree['parameters/conditions/idle'] = true
			else:
				if $"Sounds/bg/sfx/walk".playing:
					$"Sounds/bg/sfx/walk".playing = false
		
		if Input.is_action_just_pressed("attack"):
			$"Sounds/bg/sfx/attack".playing = true
			anim_tree['parameters/conditions/attack'] = true
		else:
			anim_tree['parameters/conditions/attack'] = false

	move_and_slide()
	
func unlock_glasses():
	$"Sounds/bg/sfx/get".playing = true
	has_glasses = true

func _on_sword_hitbox_body_entered(body):
	if body.has_method("is_hitable"):
		body.hit(1)
	pass

func hit():
	health -= 1
	if health > 0:
		$"Sounds/bg/sfx/skeleton_attack".playing = true
		$"Sounds/bg/sfx/damage".playing = true
		anim_tree['parameters/conditions/hit'] = true
		await get_tree().create_timer(0.3).timeout
		anim_tree['parameters/conditions/hit'] = false
	else:
		$"Sounds/bg/sfx/death".playing = true
		$"..".has_died = true
		anim_tree['parameters/conditions/death'] = true
		velocity = Vector2.ZERO

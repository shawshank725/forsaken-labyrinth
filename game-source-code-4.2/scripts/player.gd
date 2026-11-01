extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -400.0
var CARTOON_JUMP_6462 = load("res://assets/Sounds/cartoon-jump-6462.mp3")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim = get_node("AnimatedSprite2D")
@onready var MusicPlayer = $MusicPlayer

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		if get_node("AnimatedSprite2D").animation !="death":
			anim.play("fall")

	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if get_node("AnimatedSprite2D").animation !="death":
			anim.play("jump")
			MusicPlayer.stream = preload("res://assets/Sounds/jump.wav")
			MusicPlayer.play()

	var direction = Input.get_axis("ui_left", "ui_right")
	
	if direction == 1:
		get_node("AnimatedSprite2D").flip_h = false
	elif direction == -1:
		get_node("AnimatedSprite2D").flip_h = true
	
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if velocity.y == 0:
		if get_node("AnimatedSprite2D").animation != "death":
			if velocity.x ==0:
				anim.play("idle")
			else:
				anim.play("run")
	
	move_and_slide()

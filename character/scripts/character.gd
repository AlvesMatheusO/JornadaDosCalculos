extends CharacterBody2D

class_name Character

var _state_machine
var is_dead: bool = false
var _is_attacking: bool = false
var boss_hit_count: int = 0  # Adicione esta linha
@onready var audio_player = $AudioStreamPlayer  
@onready var sword = $Sword

@export_category("Variables")
@export var _move_speed: float = 150.0  
@export var _friction: float = 0.3     
@export var _acceleration: float = 0.3

@export_category("Objects")
@export var _atack_timer: Timer = null
@export var _animation_tree: AnimationTree = null 
@onready var hud = preload("res://questions/math_test.tscn").instantiate()
@onready var defeatScreen = preload("res://defeat.tscn").instantiate()

func _ready() -> void:
	audio_player.play()
	_animation_tree.active = true
	_state_machine = _animation_tree["parameters/playback"]
	add_child(hud)
	hud.hide()
	
	# Encontrar e conectar o slime
	var slime = $slime
	if slime != null:
		slime.connect("slime_died", Callable(self, "_on_Slime_died"))

func _physics_process(_delta: float) -> void:
	if is_dead:
		return
		
	_move()
	_attack()
	_animate()
	move_and_slide()

func _move() -> void:
	var _direction: Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	if _direction != Vector2.ZERO:
		_animation_tree["parameters/idle/blend_position"] = _direction
		_animation_tree["parameters/walk/blend_position"] = _direction
		_animation_tree["parameters/attack/blend_position"] = _direction
		velocity.x = lerp(velocity.x, _direction.normalized().x * _move_speed, _acceleration)
		velocity.y = lerp(velocity.y, _direction.normalized().y * _move_speed, _acceleration)
		return

	velocity.x = lerp(velocity.x, _direction.normalized().x * _move_speed, _friction)
	velocity.y = lerp(velocity.y, _direction.normalized().y * _move_speed, _friction)

func _attack() -> void:
	if Input.is_action_just_pressed("attack") and _is_attacking == false:
		set_physics_process(false)
		_atack_timer.start()
		_is_attacking = true
		sword.play()

func _animate() -> void: 
	if is_dead: 
		_state_machine.travel("death")
		return
		
	if _is_attacking:
		_state_machine.travel("attack")
		return
		
	if velocity.length() > 8:
		_state_machine.travel("walk")
		return 
		
	_state_machine.travel("idle")

func _on_attack_timer_timeout() -> void:
	set_physics_process(true)
	_is_attacking = false

func _on_attack_area_body_entered(_body) -> void:
	if _body.is_in_group("enemy"):
		_body.update_health()
	elif _body.is_in_group("boss"):
		_body.update_health() 
			

func die() -> void: 
	is_dead = true
	_state_machine.travel("death")
	await get_tree().create_timer(1).timeout
	add_child(defeatScreen)
	defeatScreen.show()
	#get_tree().reload_current_scene()

func _on_Slime_died():
	hud.show()

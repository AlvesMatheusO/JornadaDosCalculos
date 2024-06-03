extends CharacterBody2D
class_name Boss

var _is_dead: bool = false
@export var _move_speed: float = 60.0
@export_category("Objects")
@export var _texture: Sprite2D = null
@export var _animation: AnimationPlayer = null
@onready var hud = preload("res://questions/math_test.tscn").instantiate()
@onready var audio_player = $AudioStreamPlayer  # Referência ao AudioStreamPlayer
var _player_ref = null
var is_dead: bool = false

signal boss_died

var boss_question = [
	{
		"question" : "Você tinha 10 maçãs, mas um monstro comeu 6 da sua bolsa, quantas maçãs você tem agora?", 
		"choices" : ["4", "5", "6", "7"] as Array[String], 
		"correct" : 0
	}
]

func _ready() -> void:
	add_child(hud)
	hud.hide()

	if _animation == null:
		print("AnimationPlayer node not found!")
	if _texture == null:
		print("Sprite2D node not found!")

func update_health() -> void:
	if _is_dead:
		return
	_is_dead = true
	_on_boss_died()

func _on_detection_area_body_entered(_body) -> void:
	if _body.is_in_group("character"):
		_player_ref = _body
		audio_player.play()  # Toca o som quando o personagem entra na área

func _on_detection_area_body_exited(_body):
	if _body.is_in_group("character"):
		_player_ref = null

func _on_boss_died() -> void:
	if is_dead:
		return

	is_dead = true
	_animation.play("death")
	emit_signal("boss_died")
	var question_data = boss_question[randi() % boss_question.size()]
	var choices: Array[String] = question_data["choices"] as Array[String]
	hud.show_question(question_data["question"], choices, question_data["correct"])

func _physics_process(_delta: float) -> void:
	if _player_ref == null or is_dead:
		return
	if _player_ref != null:
		var _direction: Vector2 = global_position.direction_to(_player_ref.global_position)
		velocity = _direction * _move_speed
		_animate()
		move_and_slide()
		# Check collision with the player
		if global_position.distance_to(_player_ref.global_position) < 100:
			_player_ref.die()
			_player_ref.is_dead = true
			_player_ref._state_machine.travel("death")

func _on_area_2d_body_entered(_body):
	if _is_dead:
		return
	
	if _body.is_in_group("character"):	
		print("Player entered boss's detection area")
		if _player_ref != null and not _player_ref.is_dead:
			print("Attacking player")
			var direction: Vector2 = global_position.direction_to(_player_ref.global_position)
			var distance: float = global_position.distance_to(_player_ref.global_position)
			_player_ref.die()
			_player_ref.is_dead = true
			_player_ref._state_machine.travel("death")
			velocity = direction * 100
			move_and_slide()

func _animate() -> void:
	if is_dead:
		return
		
	if velocity.x > 0:
		_texture.flip_h = true
	elif velocity.x < 0:
		_texture.flip_h = false
	
	if velocity != Vector2.ZERO:
		if _animation:
			_animation.play("walk")
	else:
		if _animation:
			_animation.play("idle")

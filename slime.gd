extends CharacterBody2D
class_name Slime

var _is_dead: bool = false
var _player_ref = null

@export_category("Objects")
@export var _texture: Sprite2D = null
@export var _animation: AnimationPlayer = null
@onready var hud = preload("res://questions/math_test.tscn").instantiate()

# Lista de perguntas, escolhas e índice da resposta correta
var questions = [
	{
		"question": "Você entrou nesta caverna há 14 dias, há quantas semanas está aqui?", 
		"choices": ["1 semana", "2 semanas", "3 semanas", "4 semanas"] as Array[String], 
		"correct": 1
	},
	{
		"question": "3 + 5 = ?", 
		"choices": ["5", "6", "7", "8"] as Array[String], 
		"correct": 3
	},
	{
		"question": "6 / 2 = ?", 
		"choices": ["2", "3", "4", "5"] as Array[String], 
		"correct": 1
	},
	{
		"question": "5 * 2 = ?", 
		"choices": ["5", "8", "9", "10"] as Array[String], 
		"correct": 3
	},
	{
		"question": "5 * 3 = ?", 
		"choices": ["5", "15", "9", "10"] as Array[String], 
		"correct": 1
	},
	{
		"question": "3 * 2 = ?", 
		"choices": ["3", "12", "6", "2"] as Array[String], 
		"correct": 2
	},
	{
		"question": "Qual desses números NÃO É um múltiplo de 2?", 
		"choices": ["5", "100", "36", "10"] as Array[String], 
		"correct": 0
	}
]

func _ready() -> void:
	if not hud.is_inside_tree():
		add_child(hud)

func _on_detection_area_body_entered(_body) -> void:
	if _body.is_in_group("character"):
		_player_ref = _body

func _on_detection_area_body_exited(_body):
	if _body.is_in_group("character"):
		_player_ref = null

func _physics_process(_delta: float) -> void:
	if _is_dead:
		return
		
	_animate()

	if _player_ref != null:
		if _player_ref.is_dead:
			velocity = Vector2.ZERO
			move_and_slide()
			return
		
		var _direction: Vector2 = global_position.direction_to(_player_ref.global_position)
		var _distance: float = global_position.distance_to(_player_ref.global_position)
		
		if _distance < 40:
			_player_ref.die()
			_player_ref.is_dead = true
			_player_ref._state_machine.travel("death")
			
		velocity = _direction * 40
		move_and_slide()
	

func _animate() -> void:
	if velocity.x > 0:
		_texture.flip_h = false
		
	if velocity.x < 0: 
		_texture.flip_h = true
	
	if velocity != Vector2.ZERO:
		_animation.play("walk")
		return
		
	_animation.play("idle")

signal slime_died

func update_health() -> void:
	_is_dead = true
	_on_Slime_died()
	
func _on_Slime_died():
	# Escolha uma pergunta aleatória
	var question_data = questions[randi() % questions.size()]
	# Garanta que choices é do tipo Array[String]
	var choices: Array[String] = question_data["choices"] as Array[String]
	hud.show_question(question_data["question"], choices, question_data["correct"])
	_animation.play("death")
	emit_signal("slime_died")


func _on_area_2d_body_entered(_body):
	if _body.is_in_group("character"):	
		print("Player entered Slime's detection area")
		if _player_ref != null and not _player_ref.is_dead and _is_dead != true:
			print("Attacking player")
			var direction: Vector2 = global_position.direction_to(_player_ref.global_position)
			var distance: float = global_position.distance_to(_player_ref.global_position)
			_player_ref.die()
			_player_ref.is_dead = true
			_player_ref._state_machine.travel("death")
			velocity = direction * 40
			move_and_slide()



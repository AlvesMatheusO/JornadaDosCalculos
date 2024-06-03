extends CenterContainer

@onready var restart_button = $VBoxContainer/Button

func _ready() -> void:
	restart_button.connect("pressed", Callable(self, "_on_RestartButton_pressed"))

func _on_RestartButton_pressed() -> void:
	get_tree().change_scene_to_file("res://terrain/scenes/level.tscn")

extends Control
@onready var audio_player = $Wind

func _ready() -> void:
	audio_player.play()
	
func _on_button_pressed():
	get_tree().change_scene_to_file("res://terrain/scenes/level.tscn")
	pass # Replace with function body.


func _on_button_2_pressed():
	get_tree().quit()
	pass

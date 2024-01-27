extends Node2D


@export var mainGameScene : PackedScene #We can put main game scene into this variable so after starting game it should automatically move to it.


func _on_new_game_button_button_up():
	get_tree().change_scene_to_packed(mainGameScene)


func _on_exit_button_button_up():
	get_tree().quit()

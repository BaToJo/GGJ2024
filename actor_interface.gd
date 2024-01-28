extends Node2D

@export var Is_Player: bool = false:
	set(new_value):
		Is_Player = new_value
		$CharacterBody2D.Is_Player = new_value
		notify_property_list_changed()

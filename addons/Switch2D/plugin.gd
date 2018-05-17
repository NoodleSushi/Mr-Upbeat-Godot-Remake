tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("Switch2D","Node2D",preload("Switch2D.gd"),preload("icon16.png"))

func _exit_tree():
	remove_custom_type("Switch2D")
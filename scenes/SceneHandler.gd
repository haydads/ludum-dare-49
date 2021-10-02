extends Node


var GameScene = preload("res://scenes/GameScene.tscn")


func _ready():
	get_node("MainMenu/MarginContainer/VBoxContainer/NewGame").connect("pressed", self, "on_new_game_pressed")
	get_node("MainMenu/MarginContainer/VBoxContainer/Quit").connect("pressed", self, "on_quit_pressed")


func on_new_game_pressed():
	get_node("MainMenu").queue_free()
	var game_scene = GameScene.instance()
	add_child(game_scene)


func on_quit_pressed():
	get_tree().quit()

extends Node


var MainMenu = preload("res://scenes/main-menu/MainMenu.tscn")
var GameScene = preload("res://scenes/GameScene.tscn")
var MapSelect = preload("res://scenes/main-menu/MapSelect.tscn")
var HowToPlay = preload("res://scenes/main-menu/Tutorial.tscn")
var Map1 = preload("res://scenes/maps/Map1.tscn")
var Map2 = preload("res://scenes/maps/Map2.tscn")
var Map3 = preload("res://scenes/maps/Map3.tscn")


func _ready():
	get_node("MainMenu/MarginContainer/VBoxContainer/NewGame").connect("pressed", self, "on_new_game_pressed")
	get_node("MainMenu/MarginContainer/VBoxContainer/HowToPlay").connect("pressed", self, "how_to_play_pressed")
	get_node("MainMenu/MarginContainer/VBoxContainer/Quit").connect("pressed", self, "on_quit_pressed")
	get_node("MapSelect/MarginContainer/VBoxContainer/Map1").connect("pressed", self, "select_map1")
	get_node("MapSelect/MarginContainer/VBoxContainer/Map2").connect("pressed", self, "select_map2")
	get_node("MapSelect/MarginContainer/VBoxContainer/Map3").connect("pressed", self, "select_map3")


func on_new_game_pressed():
	get_node("MainMenu").visible = false
	get_node("MapSelect").visible = true


func on_quit_pressed():
	get_tree().quit()


func how_to_play_pressed():
	get_node("MainMenu").visible = false
	var tutorial = HowToPlay.instance()
	add_child(tutorial)


func select_map1():
	get_node("MapSelect").visible = false
	var game_scene = GameScene.instance()
	add_child(game_scene)
	var map = Map1.instance()
	map.set_name("Map")
	game_scene.add_child(map)
	game_scene.rearrange()


func select_map2():
	get_node("MapSelect").visible = false
	var game_scene = GameScene.instance()
	add_child(game_scene)
	var map = Map2.instance()
	map.set_name("Map")
	game_scene.add_child(map)
	game_scene.rearrange()


func select_map3():
	get_node("MapSelect").visible = false
	var game_scene = GameScene.instance()
	add_child(game_scene)
	var map = Map3.instance()
	map.set_name("Map")
	game_scene.add_child(map)
	game_scene.rearrange()


func get_main_menu():
	get_node("MainMenu").visible = true
	get_node("GameScene").queue_free()
	
	
func go_to_main_menu():
	get_node("MainMenu").visible = true

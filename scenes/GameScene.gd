extends Node2D


signal game_finished(result)


var map_health = 100
var map_node
var build_mode = false
var is_valid = false
var build_location
var build_type
var current_wave = 0
var wave_size = 0

func _ready() -> void:
	map_node = get_node("TestMap")
	for button in get_tree().get_nodes_in_group("build_button"):
		button.connect("pressed", self, "enter_build_mode", [button.get_name()])

func _process(delta: float) -> void:
	if build_mode:
		update_tower_preview()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel") and build_mode:
		cancel_build_mode()
		
	if event.is_action_released("ui_accept") and build_mode:
		verify_and_build()
		
	if event.is_action_pressed("toggle_grid"):
		toggle_grid()


func toggle_grid():
	var grid = get_node("Grid")
	if grid.visible:
		grid.visible = false
	else:
		grid.visible = true


func enter_build_mode(tower_type):
	if build_mode:
		cancel_build_mode()
	build_type = tower_type
	build_mode = true
	get_node("Interface").set_tower_preview(build_type, get_global_mouse_position())


func update_tower_preview():
	var mouse_position = get_global_mouse_position()
	var current_tile = map_node.get_node("ExclusionMap").world_to_map(mouse_position)
	var tile_position = map_node.get_node("ExclusionMap").map_to_world(current_tile)
	
	if map_node.get_node("ExclusionMap").get_cellv(current_tile) == -1:
		get_node("Interface").update_tower_preview(tile_position, Color(0, 1, 0, 1))
		is_valid = true
		build_location = tile_position
	else:
		get_node("Interface").update_tower_preview(tile_position, Color(1, 0, 0, 1))
		is_valid = false


func cancel_build_mode():
	build_mode = false
	is_valid = false
	get_node("Interface/TowerPreview").free()


func verify_and_build():
	if is_valid:
		var tower_tile = map_node.get_node("ExclusionMap").world_to_map(build_location)
		var tower = load("res://scenes/towers/" + build_type + ".tscn").instance()
		tower.position = build_location
		tower.is_built = true
		tower.type = build_type
		tower.health = GameData.tower_data[build_type].health
		tower.max_health = tower.health
		tower.category = GameData.tower_data[build_type].category
		tower.distance = GameData.tower_data[build_type].distance
		map_node.get_node("ExclusionMap").set_cellv(tower_tile, 1)
		map_node.get_node("Towers").add_child(tower, true)
	cancel_build_mode()


func start_next_wave():
	var wave_data = retrieve_wave_data()
	yield(get_tree().create_timer(0.2), "timeout")
	spawn_enemies(wave_data)


func retrieve_wave_data():
	var wave_data = []
	for enemy in 50:
		wave_data.append(["enemy_1", 0.5])
	current_wave +=1
	wave_size = wave_data.size()
	return wave_data


func spawn_enemies(wave_data):
	for enemy in wave_data:
		var new_enemy = load("res://scenes/enemies/" + enemy[0] + ".tscn").instance()
		new_enemy.connect("damage_base", self, "damage_base")
		map_node.get_node("Path").add_child(new_enemy, true)
		yield(get_tree().create_timer(enemy[1]), "timeout")


func damage_base(damage):
	map_health -= damage
	if map_health <= 0:
		emit_signal("game_finished", false)
	else:
		get_node("Interface/HUD/VBoxContainer/PanelContainer/HBoxContainer3/Health/Label").set_text(str(map_health))
	

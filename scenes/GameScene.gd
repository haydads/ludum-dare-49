extends Node2D


signal wave_stopped()
signal wave_started()


var current_cash = 1000
var map_health = 100
var map_node
var build_mode = false
var is_valid = false
var build_location
var build_type
var current_wave = 0
var wave_size = 0
var game_finished := false
var wave_counter := 30.0


func _ready() -> void:
	get_node("Interface/GameOverScreen/CenterContainer/VBoxContainer/Button").connect("pressed", self, "quit_to_menu")
	for button in get_tree().get_nodes_in_group("build_button"):
		button.connect("pressed", self, "enter_build_mode", [button.get_name()])


func _process(delta: float) -> void:
	if build_mode:
		update_tower_preview()
	toggle_grid()
	update_wave_counter(delta)
	check_tower_unlock()
	get_node("Interface/HUD/VBoxContainer/PanelContainer/HBoxContainer3/Money/Amount").set_text(str(current_cash))


func check_tower_unlock():
	if wave_size == 0:		
		match current_wave:
			2:	
				get_node("Interface/HUD/VBoxContainer/PanelContainer2/MarginContainer/BuildMenu/tower_2").visible = true
				get_node("Interface/HUD/VBoxContainer/PanelContainer2/MarginContainer/BuildMenu/tower_3").visible = true
			4:	get_node("Interface/HUD/VBoxContainer/PanelContainer2/MarginContainer/BuildMenu/tower_4").visible = true
			7:	get_node("Interface/HUD/VBoxContainer/PanelContainer2/MarginContainer/BuildMenu/tower_5").visible = true
			12:	get_node("Interface/HUD/VBoxContainer/PanelContainer2/MarginContainer/BuildMenu/tower_6").visible = true
			15: get_node("Interface/HUD/VBoxContainer/PanelContainer2/MarginContainer/BuildMenu/tower_7").visible = true


func rearrange():
	map_node = get_node("Map")
	move_child(get_node("Map"), 1)


func update_wave_counter(delta):
	if wave_size == 0:
		if wave_counter <= 0:
			start_next_wave()
		else:
			get_node("Interface/HUD/VBoxContainer/IncomingWave").visible = true
			get_node("Interface/HUD/VBoxContainer/IncomingWave/Label").set_text("Incoming Wave in %s seconds" % int(wave_counter))
			wave_counter -= 1 * delta


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel") and build_mode:
		cancel_build_mode()
	if event.is_action_released("ui_accept") and build_mode:
		verify_and_build()
	if event.is_action_pressed("menu"):
		var menu = get_node("Interface/MenuScreen")
		if menu.visible:
			menu.visible = false
		else:
			menu.visible = true	


func toggle_grid():
	var grid = get_node("Grid")
	if build_mode:
		grid.visible = true
	else:
		grid.visible = false


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
	
	var cost = GameData.tower_data[build_type].cost
	if map_node.get_node("ExclusionMap").get_cellv(current_tile) == -1 and current_cash >= cost:
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
	var cost = GameData.tower_data[build_type].cost
	if is_valid and current_cash >= cost:
		var tower_tile = map_node.get_node("ExclusionMap").world_to_map(build_location)
		var tower = load("res://scenes/towers/" + build_type + ".tscn").instance()
		tower.position = build_location
		tower.is_built = true
		tower.type = build_type
		tower.health = GameData.tower_data[build_type].health
		tower.max_health = tower.health
		connect("wave_started", tower, "wave_started")
		connect("wave_stopped", tower, "wave_stopped")
		tower.category = GameData.tower_data[build_type].category
		tower.distance = GameData.tower_data[build_type].distance
		map_node.get_node("ExclusionMap").set_cellv(tower_tile, 1)
		map_node.get_node("Towers").add_child(tower, true)
		current_cash -= cost
	cancel_build_mode()


func start_next_wave():
	emit_signal("wave_started")
	current_wave += 1
	wave_counter = 10.0
	get_node("Interface/HUD/VBoxContainer/IncomingWave").visible = false
	get_node("Interface/HUD/VBoxContainer/PanelContainer/HBoxContainer3/CenterContainer/Label").set_text("wave %s" % current_wave)
	var wave_data = retrieve_wave_data()
	yield(get_tree().create_timer(0.2), "timeout")
	spawn_enemies(wave_data)


func retrieve_wave_data():
	var wave_data = GameData.get_enemy_wave(current_wave)
	wave_size = wave_data.size()
	return wave_data


func spawn_enemies(wave_data):
	for enemy in wave_data:
		var new_enemy = load("res://scenes/enemies/" + enemy[0] + ".tscn").instance()
		new_enemy.type = enemy[0]
		new_enemy.connect("damage_base", self, "damage_base")
		new_enemy.connect("killed", self, "enemy_killed")
		map_node.get_node("Path").add_child(new_enemy, true)
		yield(get_tree().create_timer(enemy[1], false), "timeout")


func damage_base(unit, damage):
	get_node(unit.get_path()).disconnect("damage_base", self, "damage_base")
	wave_size -= 1
	map_health -= damage
	if map_health <= 0:
		finish_game()
	get_node("Interface/HUD/VBoxContainer/PanelContainer/HBoxContainer3/Health/Label").set_text(str(map_health))


func enemy_killed(unit, value):
	get_node(unit.get_path()).disconnect("killed", self, "enemy_killed")
	current_cash += value
	wave_size -= 1
	if wave_size == 0:
		emit_signal("wave_stopped")
		Engine.set_time_scale(1.0)
		if current_wave == 100:
			finish_game()


func finish_game():
	game_finished = true
	Engine.set_time_scale(1.0)
	map_health = 0
	
	get_node("Interface/GameOverScreen").visible = true
	get_node("Interface/GameOverScreen/CenterContainer/VBoxContainer/Label2").set_text("You survived to wave %s" % current_wave)
	get_node("Interface/HUD/VBoxContainer").visible = false


func quit_to_menu():
	queue_free()
	get_parent().go_to_main_menu()

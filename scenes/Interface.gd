extends CanvasLayer


var range_texture = preload("res://assets/towers/range_overlay.png")


func _ready():
	get_node("HUD/VBoxContainer/MarginContainer2/Controls/Pause").connect("pressed", self, "pause_pressed")
	get_node("HUD/VBoxContainer/MarginContainer2/Controls/Play").connect("pressed", self, "play_pressed")
	get_node("HUD/VBoxContainer/MarginContainer2/Controls/Fast").connect("pressed", self, "fast_pressed")
	get_node("MenuScreen/CenterContainer/VBoxContainer/Continue").connect("pressed", self, "continue_pressed")
	get_node("MenuScreen/CenterContainer/VBoxContainer/Quit").connect("pressed", self, "quit_pressed")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_pause"):
		pause_pressed()
		
	if event.is_action_pressed("game_play"):
		play_pressed()

	if event.is_action_pressed("game_fast"):
		fast_pressed()

	
		


func set_tower_preview(tower_type, mouse_position):
	var drag_tower = load("res://scenes/towers/" + tower_type + ".tscn").instance()
	drag_tower.set_name("DragTower")
	drag_tower.modulate = Color(0, 1, 0, 1)
	
	var range_indicator = Sprite.new()
	range_indicator.position = Vector2(32, 32)
	var scaling = (GameData.tower_data[tower_type].distance * 2) / 960.0
	range_indicator.scale = Vector2(scaling, scaling)
	range_indicator.texture = range_texture
	range_indicator.set_name("Range")
	
	var control = Control.new()
	control.rect_position = mouse_position
	control.set_name("TowerPreview")
	control.add_child(drag_tower, true)
	control.add_child(range_indicator, true)
	add_child(control, true)
	move_child(get_node("TowerPreview"), 0) # Move behind HUD
	

func update_tower_preview(new_position, color):
	get_node("TowerPreview").rect_position = new_position
	if get_node("TowerPreview/DragTower").modulate != color:
		get_node("TowerPreview/DragTower").modulate = color


func pause_pressed():
	if !get_tree().is_paused() and !get_parent().game_finished:
		pause_game()
	else:
		unpause_game()


func pause_game():
	get_tree().paused = true
	get_node("HUD/PauseScreen").visible = true
	if get_parent().build_mode:
		get_parent().cancel_build_mode()
	get_node("HUD/VBoxContainer/PanelContainer2").visible = false


func unpause_game():
	get_tree().paused = false
	get_node("HUD/PauseScreen").visible = false
	get_node("HUD/VBoxContainer/PanelContainer2").visible = true


func play_pressed():
	unpause_game()
	Engine.set_time_scale(1.0)
	#print(get_parent().current_wave)
	if get_parent().wave_size <= 0:
		get_parent().start_next_wave()


func fast_pressed():
	unpause_game()
	Engine.set_time_scale(2.0)
	if get_parent().wave_size <= 0:
		get_parent().start_next_wave()


func continue_pressed():
	get_node("MenuScreen").visible = false
	get_node("HUD").visible = true
	
	
func restart_pressed():
	pass
	

func quit_pressed():
	get_parent().queue_free()
	get_node("../..").go_to_main_menu()
	#get_parent().queue_free()
	#get_parent().queue_free()
	

extends CanvasLayer


var range_texture = preload("res://assets/towers/range_overlay.png")
#var tower_range = 352

func _ready():
	get_node("HUD/VBoxContainer/MarginContainer2/Controls/Pause").connect("pressed", self, "pause_pressed")
	get_node("HUD/VBoxContainer/MarginContainer2/Controls/Play").connect("pressed", self, "play_pressed")
	get_node("HUD/VBoxContainer/MarginContainer2/Controls/Fast").connect("pressed", self, "fast_pressed")


func set_tower_preview(tower_type, mouse_position):
	var drag_tower = load("res://scenes/towers/" + tower_type + ".tscn").instance()
	drag_tower.set_name("DragTower")
	drag_tower.modulate = Color(0, 1, 0, 1)
	
	var range_indicator = Sprite.new()
	range_indicator.position = Vector2(32, 32)
	var scaling = (GameData.tower_data[tower_type].distance * 2) / 600.0
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
	if get_tree().is_paused() == false:
		get_tree().paused = true
	else:
		get_tree().paused = false
	if get_parent().build_mode:
		get_parent().cancel_build_mode()


func play_pressed():
	get_tree().paused = false
	Engine.set_time_scale(1.0)
	if get_parent().current_wave == 0:
		get_parent().start_next_wave()


func fast_pressed():
	get_tree().paused = false
	Engine.set_time_scale(2.0)

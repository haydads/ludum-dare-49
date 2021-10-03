extends Node2D
class_name Tower


var random = RandomNumberGenerator.new()
var type
var category
var health : float
var max_health : float
var distance
var kills = 0
var target_array = []
var tower_array = []
var is_built := false
var target = null
var can_shoot := true
var is_unstable := false
var time_to_unstable := 0.0
var time_to_explode := 0.0
var get_new_rotation = true
var show_health := false
var show_stats := false
var health_timer := 0.0
var wave_in_progress := false


func _ready():
	if is_built:
		get_node("Range").connect("body_entered", self, "entered_range")
		get_node("Range").connect("body_exited", self, "exited_range")
		self.get_node("Range/CollisionShape2D").get_shape().radius = GameData.tower_data[type].distance
		
		get_node("Button").visible = true
		get_node("Button").connect("mouse_entered", self, "stabilize")
		random.randomize()
		time_to_unstable = random.randf_range(10.0, 30.0)
		
		health = GameData.tower_data[type].health
		max_health = health


func _physics_process(delta):	
	if is_built:
		if !is_instance_valid(target):
			target = null
		check_stability(delta)
		update_health_timer(delta)
		if (target_array.size() != 0 and !is_unstable) or (tower_array.size() != 0 and is_unstable):
			select_target()
			if target != null:
				if not get_node("AnimationPlayer").is_playing():
					aim()
				if can_shoot:
					fire()
		else:
			pass
			#target = null
			#random_aim()
		if get_node("Button").pressed:
			show_stats = true
		else:
			show_stats = false
		update()


func _draw():
	if show_health: #or (show_stats and !is_unstable):
		draw_arc(Vector2(32, 32), 36, deg2rad(0), deg2rad((360 / max_health) * health), 360, Color(0, 1, 0, 1), 4.0, true)
	if show_stats and !is_unstable:
		draw_arc(Vector2(32, 32), 36, deg2rad(0), deg2rad((360 / max_health) * health), 360, Color(0, 1, 0, 1), 4.0, true)
		draw_circle(Vector2(32, 32), distance, Color(1, 1, 1, 0.05))


func update_health_timer(delta):
	if show_health:
		if health_timer <= 0.0:
			show_health = false
			health_timer = 1.0
		else:
			health_timer -= 1.0 * delta


func random_aim():
	pass
	#if get_new_rotation:
		#get_new_rotation = false
		#var random_vector = Vector2(random.randf_range(-1.0, 1.0) * 32, random.randf_range(-1.0, 1.0) * 32)
		#get_node("Sprite").look_at(global_position + Vector2(32, 32) + random_vector)
		#yield(get_tree().create_timer(random.randi_range(1, 5)), "timeout")
		#get_new_rotation = true


func aim():
	if is_instance_valid(target):
		if is_unstable:
			get_node("Sprite").look_at(target.position + Vector2(32, 32))
		else:
			get_node("Sprite").look_at(target.position)


func fire():
	if is_instance_valid(target):
		can_shoot = false
		if category == "Projectile":
			fire_gun()
		target.on_hit(GameData.tower_data[type].damage)
		yield(get_tree().create_timer(GameData.tower_data[type].rate_of_fire), "timeout")
		can_shoot = true


func on_hit(damage):
	health -= damage
	health_timer = 1.0
	show_health = true
	if health <= 0:
		#killer.target = null
		#killer.kills += 1
		var tile = get_node("../../ExclusionMap").world_to_map(global_position)
		get_node("../../ExclusionMap").set_cellv(tile, -1)
		self.queue_free()


func fire_gun():
	get_node("AnimationPlayer").play("Fire")


func entered_range(body):
	target_array.append(body.get_parent())


func exited_range(body):
	target_array.erase(body.get_parent())


func select_target():
	var target_progress_array = []
	if is_unstable and target == null:
		for tower in tower_array:
			if is_instance_valid(tower):
				target_progress_array.append(position.distance_to(tower.position))
			if target_progress_array.size() > 0:
				var min_distance = target_progress_array.min()
				var target_index = target_progress_array.find(min_distance)
				target = tower_array[target_index]
	elif !is_unstable:
		for enemy in target_array:
			target_progress_array.append(enemy.offset)
			var max_offset = target_progress_array.max()
			var enemy_index = target_progress_array.find(max_offset)
			target = target_array[enemy_index]


func check_stability(delta):
	if is_unstable and target == null:
		#target_array.clear()
		tower_array.clear()
		for tower in get_parent().get_children():
			if tower != self and position.distance_to(tower.position) < distance + 31:
				tower_array.append(tower)
	else:
		if !is_unstable and wave_in_progress:
			if time_to_unstable > 0:
				time_to_unstable -= 1 * delta
			else:
				is_unstable = true
				get_node("Unstable").visible = true
				#target_array.clear()
				tower_array.clear()


func stabilize():
	if is_unstable:
		target = null
		tower_array.clear()
		is_unstable = false
		time_to_unstable = random.randf_range(10.0, 30.0)
		get_node("Unstable").visible = false


func wave_stopped():
	wave_in_progress = false


func wave_started():
	wave_in_progress = true

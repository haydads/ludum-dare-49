extends Node2D
class_name Tower


var random = RandomNumberGenerator.new()
var type
var category
var health = 50
var max_health = health
var distance
var kills = 0
var target_array = []
var is_built := false
var target = null
var can_shoot := true
var is_unstable := false
var time_to_unstable := 0.0
var time_to_explode := 0.0
var get_new_rotation = true
var show_health = false


func _ready():
	if is_built:
		get_node("Range").connect("body_entered", self, "entered_range")
		get_node("Range").connect("body_exited", self, "exited_range")
		self.get_node("Range/CollisionShape2D").get_shape().radius = GameData.tower_data[type].distance
		get_node("Button").visible = true
		get_node("Button").connect("pressed", self, "stabilize")
		random.randomize()
		time_to_unstable = random.randf_range(10.0, 30.0)
		


func _physics_process(delta):	
	if is_built:
		if !is_instance_valid(target):
			target = null
			
		check_stability(delta)
		
		if target_array.size() != 0:
			select_target()
			if target != null:
				if not get_node("AnimationPlayer").is_playing():
					aim()
				if can_shoot:
					fire()
		else:
			target = null
			random_aim()
		
		if get_node("Button").pressed:
			show_health = true
		else:
			show_health = false


func _draw():
	if show_health:
		draw_arc(Vector2(32, 32), 24, deg2rad(-10) , deg2rad((360 / max_health) * health), health, Color(0, 1, 0, 1), 4.0, true)

func random_aim():
	if get_new_rotation:
		get_new_rotation = false
		var random_vector = Vector2(random.randf_range(-1.0, 1.0) * 32, random.randf_range(-1.0, 1.0) * 32)
		get_node("Sprite").look_at(global_position + Vector2(32, 32) + random_vector)
		yield(get_tree().create_timer(random.randi_range(1, 5)), "timeout")
		get_new_rotation = true


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
		target.on_hit(GameData.tower_data[type].damage, self)
		yield(get_tree().create_timer(GameData.tower_data[type].rate_of_fire), "timeout")
		can_shoot = true


func on_hit(damage, killer):
	health -= damage
	if health <= 0:
		killer.target = null
		killer.kills += 1
		var tile = get_node("../../ExclusionMap").world_to_map(global_position)
		get_node("../../ExclusionMap").set_cellv(tile, -1)
		
		self.queue_free()
		#var tower_tile = map_node.get_node("ExclusionMap").world_to_map(build_location)


func on_destroy():
	self.queue_free()


func fire_gun():
	get_node("AnimationPlayer").play("Fire")
	pass


func entered_range(body):
	#print(body.get_parent())
	target_array.append(body.get_parent())


func exited_range(body):
	target_array.erase(body.get_parent())


func select_target():
	var target_progress_array = []
	if is_unstable and target == null:
		for tower in target_array:
			if is_instance_valid(tower):
				target_progress_array.append(position.distance_to(tower.position))
			if target_progress_array.size() > 0:
				var min_distance = target_progress_array.min()
				var target_index = target_progress_array.find(min_distance)
				target = target_array[target_index]
			
	elif !is_unstable:
		for enemy in target_array:
			target_progress_array.append(enemy.offset)
			var max_offset = target_progress_array.max()
			var enemy_index = target_progress_array.find(max_offset)
			target = target_array[enemy_index]


func check_stability(delta):
	if is_unstable and target == null:
		#print(self.get_name() + " needs target")
		target_array.clear()
		for tower in get_parent().get_children():
			if tower != self and position.distance_to(tower.position) < distance + 31:
				#print(position.distance_to(tower.position))
				target_array.append(tower)
	else:
		if !is_unstable:
			if time_to_unstable > 0:
				time_to_unstable -= 1 * delta
			else:
				#pass
				is_unstable = true
				get_node("Unstable").visible = true
				target_array.clear()


func stabilize():
	if is_unstable:
		target = null
		target_array.clear()
		is_unstable = false
		time_to_unstable = random.randf_range(10.0, 30.0)
		get_node("Unstable").visible = false

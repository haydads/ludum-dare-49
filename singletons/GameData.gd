extends Node

var random = RandomNumberGenerator.new()
var tower_data = {}
var enemy_data = {}
var enemy_waves = []


func _ready():
	tower_data.tower_1 = create_tower(8, 1, 1, 2, 40, "Projectile") 
	tower_data.tower_2 = create_tower(24, 3, 0.8, 4, 120, "Projectile")
	tower_data.tower_3 = create_tower(18, 8, 2.5, 12, 90, "Projectile")
	tower_data.tower_4 = create_tower(20, 2, 0.25, 3, 150, "Projectile")
	tower_data.tower_5 = create_tower(64, 10, 0.8, 6, 180, "Projectile")
	tower_data.tower_6 = create_tower(36, 18, 2, 16, 210, "Projectile")
	tower_data.tower_7 = create_tower(48, 6, 0.25, 5, 240, "Projectile")
	
	enemy_data.enemy_1 = create_enemy(1, 200, 1, 1, 1)
	enemy_data.enemy_2 = create_enemy(2, 250, 2, 2, 2)
	enemy_data.enemy_3 = create_enemy(4, 200, 3, 3, 3)
	enemy_data.enemy_4 = create_enemy(7, 375, 4, 5, 2)
	enemy_data.enemy_5 = create_enemy(10, 350, 8, 8, 4)
	enemy_data.enemy_6 = create_enemy(24, 100, 20, 12, 6)
	enemy_data.enemy_7 = create_enemy(12, 500, 15, 16, 7)

	enemy_waves = create_enemy_waves()

func create_tower(health, damage, rate_of_fire, distance, cost, category) -> Dictionary:
	var tower = {}
	tower.health = health
	tower.damage = damage
	tower.rate_of_fire = rate_of_fire
	tower.distance = (distance * 64) + 32
	tower.category = category
	tower.cost = cost
	return tower


func create_enemy(health, speed, damage, value, points) -> Dictionary:
	var enemy = {}
	enemy.speed = speed
	enemy.health = health
	enemy.damage = damage
	enemy.value = value
	enemy.points = points
	return enemy


func create_enemy_waves() -> Array:
	var waves = []
	for wave in 101:
		match wave:
			1: waves.append(generate_wave(1, 1, 1, 10))
			2: waves.append(generate_wave(1, 1, 1, 12))
			3: waves.append(generate_wave(2, 1, 0.5, 14))
			4: waves.append(generate_wave(2, 1, 0.5, 16))
			5: waves.append(generate_wave(3, 0.5, 0.5, 18))
			6: waves.append(generate_wave(3, 0.5, 0.5, 20))
			7: waves.append(generate_wave(4, 0.5, 0.25, 25))
			8: waves.append(generate_wave(4, 0.5, 0.25, 30))
			9: waves.append(generate_wave(4, 0.5, 0.25, 35))
			10: waves.append(generate_wave(5, 2, 0.5, 50))
			11: waves.append(generate_wave(5, 0.5, 0.25, 60))
			12: waves.append(generate_wave(6, 0.5, 0.25, 70))
			13: waves.append(generate_wave(6, 0.5, 0.25, 80))
			14: waves.append(generate_wave(7, 1, 0.5, 90))
			15: waves.append(generate_wave(7, 0.5, 0.25, 100))
			16: waves.append(generate_wave(7, 0.5, 0.25, 120))
			17: waves.append(generate_wave(7, 0.5, 0.25, 140))
			18: waves.append(generate_wave(7, 0.5, 0.25, 160))
			19: waves.append(generate_wave(7, 0.5, 0.25, 180))
			20: waves.append(generate_wave(7, 0.5, 0.25, 200))
			_: waves.append(generate_wave(7, 0.25, 0.25, floor(wave * (wave * 0.5))))
	return waves


func get_enemy_wave(index) -> Array:
	return enemy_waves[index]
	
	
func generate_wave(max_index, max_interval, min_interval, points) -> Array:
	var wave = []
	
	while points > 0:
		var index  = random.randi_range(1, max_index)
		var cost : int = enemy_data["enemy_%s" % index].points
		if cost > points:
			continue
		var interval = random.randf_range(min_interval, max_interval)
		
		wave.append(["enemy_%s" % index, interval])
		points -= cost
	#print(wave)
	return wave
	

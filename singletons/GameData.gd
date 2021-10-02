extends Node


var tower_data = {}


func _ready():
	tower_data.tower_1 = create_tower(300, 7, 0.2, 160, "Projectile")
	tower_data.tower_2 = create_tower(600, 25, 0.8, 352, "Projectile")
	#print(tower_data)


func create_tower(health, damage, rate_of_fire, distance, category) -> Dictionary:
	var tower = {}
	tower.health = health
	tower.damage = damage
	tower.rate_of_fire = rate_of_fire
	tower.distance = distance
	tower.category = category
	return tower

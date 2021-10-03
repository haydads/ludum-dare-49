extends PathFollow2D
class_name Enemy


signal damage_base(unit, damage)
signal killed(unit, value)

var type
var value = 0.0
var speed = 0.0
var health = 0.0
var damage = 0.0
var max_health = health
var show_health := false
var health_timer := 0.0


func _ready():
	speed = GameData.enemy_data[type].speed
	health = GameData.enemy_data[type].health
	damage = GameData.enemy_data[type].damage
	max_health = GameData.enemy_data[type].health
	value = GameData.enemy_data[type].value


func _physics_process(delta):
	if unit_offset == 1.0:
		emit_signal("damage_base", self, damage)
		queue_free()
	move(delta)
	update_health_timer(delta)
	#update()


#func _draw():
	#pass
	#if show_health and health > 0:
		#draw_arc(Vector2.ZERO, 24, deg2rad(0) , deg2rad((360 / max_health) * health), 360, Color(1,1,1,1), 2.0, true)


func move(delta):
	set_offset(get_offset() + speed * delta)


func on_hit(_damage):
	health -= _damage
	health_timer = 1.0
	show_health = true
	if health <= 0:
		emit_signal("killed", self, value)
		queue_free()


func update_health_timer(delta):
	if show_health:
		if health_timer <= 0.0:
			show_health = false
			health_timer = 1.0
		else:
			health_timer -= 1.0 * delta

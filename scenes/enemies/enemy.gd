extends PathFollow2D
class_name Enemy


signal damage_base(damage)


var speed = 150
var health = 50
var damage = 5
var max_health = health
var show_health = true

func _physics_process(delta):
	if unit_offset == 1.0:
		emit_signal("damage_base", damage)
		queue_free()
	move(delta)
	update()


func move(delta):
	set_offset(get_offset() + speed * delta)


func on_hit(damage, killer):
	health -= damage
	if health <= 0:
		killer.target = null
		killer.kills += 1
		self.queue_free()


#func on_destroy():
	#self.queue_free()
	
	
func _draw():
	if show_health:
	#if health != max_health:
		draw_arc(Vector2.ZERO, 24, deg2rad(-10) , deg2rad((360 / max_health) * health), health, Color(1,1,1,0.5), 4.0, true)
	else:
		draw_arc(Vector2.ZERO, 24, deg2rad(-10) , deg2rad((360 / max_health) * health), health, Color(1,1,1,0.2), 1.0, true)

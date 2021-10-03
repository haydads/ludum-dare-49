extends Button


export var type := ""


func _ready():
	get_node("Label").set_text(" %s" % str(GameData.tower_data[type].cost))

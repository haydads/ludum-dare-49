extends Control


func _ready():
	get_node("HowToPlay/ViewBasics").connect("pressed", self, "go_to_basics1")
	get_node("Basics1").connect("pressed", self, "go_to_basics2")
	get_node("Basics2").connect("pressed", self, "go_to_how_to_play")
	get_node("HowToPlay/Back").connect("pressed", self, "go_to_main_menu")
	

func go_to_basics1():
	get_node("HowToPlay").visible = false
	get_node("Basics1").visible = true
	get_node("Basics2").visible = false
	

func go_to_basics2():
	get_node("HowToPlay").visible = false
	get_node("Basics1").visible = false
	get_node("Basics2").visible = true
	
	
func go_to_how_to_play():
	get_node("HowToPlay").visible = true
	get_node("Basics1").visible = false
	get_node("Basics2").visible = false


func go_to_main_menu():
	queue_free()
	get_parent().go_to_main_menu()


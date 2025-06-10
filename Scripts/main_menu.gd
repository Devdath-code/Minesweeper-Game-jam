extends Control
@onready var click = $click


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_game_pressed():
	click.play()
	get_tree().change_scene_to_file("res://scenes/main_minesweeper.tscn")
	

func _on_exit_pressed():
	click.play()
	print("options")
	

func _on_options_pressed():
	get_tree().quit()
	click.play()

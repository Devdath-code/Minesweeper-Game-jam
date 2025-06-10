extends Node

#game variables
const TOTAL_MINES : int = 40
const TOTAL_CLUES : int = 1
var time_elapsed  : float
var remaining_mines : int
var remaining_clues : int

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()
	
func new_game():
	time_elapsed = 0
	remaining_mines = TOTAL_MINES
	remaining_clues = TOTAL_CLUES
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

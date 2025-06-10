extends Node

#game variables
const TOTAL_MINES : int = 20
const TOTAL_CLUES : int = 1
var time_elapsed  : float
var remaining_mines : int
var remaining_clues : int

#signals 
signal timer_end

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()
	
func new_game():
	time_elapsed = 30
	remaining_mines = TOTAL_MINES
	remaining_clues = TOTAL_CLUES
	tilemap_new_game()
	hide_game_over()
	get_tree().paused = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if time_elapsed > 0:
		time_elapsed -= delta
	else:
		timer_end.emit()
		
	if $HUD != null and $HUD.has_node("stopwatch"):
		$HUD.get_node("stopwatch").text = str(int(time_elapsed))
	else:
		pass
	
	if $HUD != null and $HUD.has_node("RemainingMines"):
		$HUD.get_node("RemainingMines").text = str(remaining_mines)
	else:
		pass


func tilemap_new_game():
	if $TileMap != null:
		$TileMap.new_game()
	else:
		pass
		
func hide_game_over():
	if $GameOver != null:
		$GameOver.hide()
	else:
		pass

func show_game_over():
	if $GameOver != null:
		$GameOver.show()
	else:
		pass
		
func end_game(result):
	get_tree().paused = true
	show_game_over()
	get_tree().paused = true
	if result == 1:
		if $GameOver != null:
			$GameOver.get_node("Label").text = "YOU WIN!"
		else:
			pass
	else:
		if $GameOver != null:
			$GameOver.get_node("Label").text = "BOOM!"
		else:
			pass
			
#signal functions
func _on_tile_map_flag_placed():
	remaining_mines -= 1
	print("Flag Placed")


func _on_tile_map_flag_removed():
	remaining_mines += 1
	print("Flag Placed")


func _on_tile_map_end_game():
	end_game(-1)

func _on_tile_map_game_won():
	end_game(1)

func _on_game_over_restart():
	new_game()


func _on_timer_end():
	end_game(-1)

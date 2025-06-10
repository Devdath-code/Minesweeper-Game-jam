extends TileMap

#grid variables
const ROWS : int = 14
const COLS : int = 15
const CELL_SIZE : int = 50

#tilemap variables
var tile_id : int = 1
const alt : int = 1
#layer variables
var clue_layer : int = 0
var mine_layer : int = 1
var number_layer : int = 2
var grass_layer : int = 3
var flag_layer : int = 4
var hover_layer : int = 5

#atlas coordinates
var mine_atlas := Vector2i(4, 0)
var clue_atlas := Vector2i(0,0)

#array to store mine coordinates
var mine_coords := []

#array to store clue coordinates
var clues_coords := []

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()
	
#reset game
func new_game():
	clear()
	mine_coords.clear()
	generate_mines()
	generate_clues()
	generate_numbers()
	
func generate_mines():
	for i in range(MainMinesweeper.TOTAL_MINES):
		var mine_pos = Vector2i(randi_range(0, COLS - 1), randi_range(0, ROWS - 1))
		while mine_coords.has(mine_pos):
			mine_pos = Vector2i(randi_range(0, COLS - 1), randi_range(0, ROWS - 1))
		mine_coords.append(mine_pos)
		#add mine to tilemap
		set_cell(mine_layer, mine_pos, tile_id, mine_atlas)

func generate_clues():
	for i in range(MainMinesweeper.TOTAL_CLUES):
		var clues_pos = Vector2i(randi_range(0, COLS - 1), randi_range(0, ROWS - 1))
		while clues_coords.has(clues_pos):
			clues_pos = Vector2i(randi_range(0, COLS - 1), randi_range(0, ROWS - 1))
		clues_coords.append(clues_pos)
		#add CLUE to tilemap only if there is no mine at that location
		if(get_cell_source_id(mine_layer,clues_pos) == -1):
			set_cell(clue_layer, clues_pos, tile_id,clue_atlas,alt)
		else:
			generate_clues()
			
func generate_numbers():
	#get empty cells
	get_empty_cells()
	#iterate through empty cells to find the surrounding cells 
	#add up number of mines inside surrounding cells 
	pass 
func get_empty_cells():
	var empty_cells := []
	#iterate over the grid
	for y in range(ROWS):
		for x in range(COLS):
			#check if the cell is empty and add it to the array
			var pos = Vector2i(x,y)
			if not is_mine(pos):
				if not is_clue(pos):
					empty_cells.append(pos)
	print("Empty cells found: ", empty_cells.size())
	print("Empty cells: ", empty_cells)
	return empty_cells
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#helper functions
func is_mine(pos):
	return get_cell_source_id(mine_layer,pos) != -1 

func is_clue(pos):
	return get_cell_source_id(clue_layer,pos) != -1 
		

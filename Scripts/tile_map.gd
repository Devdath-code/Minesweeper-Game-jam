extends TileMap

signal flag_placed
signal flag_removed
signal end_game
signal game_won

#grid variables
const ROWS : int = 14
const COLS : int = 15
const CELL_SIZE : int = 50
@onready var tile_click = $tile_click

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
var number_atlas : Array = generate_number_atlas()
var hover_atlas := Vector2i(6,0)
var flag_atlas := Vector2i(5,0)

#array to store mine coordinates
var mine_coords := []

#array to store clue coordinates
var clues_coords := []

func generate_number_atlas():
	var a := []
	for i in range(8):
		a.append(Vector2i(i,1))
	return a
# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()
	
#reset game
func new_game():
	clear()
	mine_coords.clear()
	clues_coords.clear()
	generate_mines()
	generate_clues()
	generate_numbers()
	generate_grass()
	
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
	for i in get_empty_cells(): 
		var mine_count: int = 0
		for j in get_all_surrounding_cells(i):
			#check if there is a mine in the cell 
			if is_mine(j):
				mine_count += 1
		#once counted, add the number cell to the tile map 
		if mine_count > 0:
				set_cell(number_layer,i,tile_id,number_atlas[mine_count-1])

func generate_grass():
	for y in range(ROWS):
		for x in range(COLS):
			var toggle = ((x+y) % 2)
			set_cell(grass_layer, Vector2i(x,y), tile_id, Vector2i(3-toggle,0))

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
	return empty_cells
	
func get_all_surrounding_cells(middle_cell):
	var surrounding_cells := []
	var target_cell
	for y in range(3):
		for x in range(3):
			target_cell = middle_cell + Vector2i(x-1,y-1 )
			#skip if it is one in the middle
			if target_cell != middle_cell:
				#check that the cell is on the grid
				if (target_cell.x>=0 and target_cell.x<= COLS -1
					and target_cell.y>=0 and target_cell.y<= ROWS -1):
					surrounding_cells.append(target_cell)
	return surrounding_cells
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event is InputEventMouseButton:
		#check if mouse is on the gameboard
		if event.position.y < ROWS * CELL_SIZE:
			var map_pos := local_to_map(event.position)
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				#check there is no flag
				if not is_flag(map_pos):
					#check if it is a mine
					if is_mine(map_pos):
						end_game.emit()
						show_mines()
						show_clues()
					else:
						process_left_click(map_pos)
						tile_click.play()
			#right click places and removes flags 
			elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				process_right_click(map_pos)
				tile_click.play()
				
func process_left_click(pos):
	var revealed_cells := []
	var cells_to_reveal := [pos]
	while not cells_to_reveal.is_empty():
		#clear the cell and mark it cleared 
		erase_cell(grass_layer,cells_to_reveal[0])
		revealed_cells.append(cells_to_reveal[0])
		#if the cells had a flag then clear it 
		if is_flag(cells_to_reveal[0]):
			erase_cell(flag_layer,cells_to_reveal[0])
			flag_removed.emit()
		if not is_number(cells_to_reveal[0]):
			cells_to_reveal = reveal_surrounding_cells(cells_to_reveal,revealed_cells)
		#remove processed cell from array 
		cells_to_reveal.erase(cells_to_reveal[0])
	#once click is processed, check if clue tile is shown
	var clue_tile_shown := true
	for cell in get_used_cells(clue_layer):
		if is_grass(cell):
			clue_tile_shown = false
	if clue_tile_shown:
		game_won.emit()
	 
func process_right_click(pos):
	#check if its a grass cell
	if is_grass(pos):
		if is_flag(pos):
			erase_cell(flag_layer,pos)
			flag_removed.emit()
		else:
			set_cell(flag_layer,pos,tile_id,flag_atlas)
			flag_placed.emit()

func reveal_surrounding_cells(cells_to_reveal, revealed_cells):
	for i in get_all_surrounding_cells(cells_to_reveal[0]):
		#check that the cell is not already revealed
		if not revealed_cells.has(i):
			if not cells_to_reveal.has(i):
				cells_to_reveal.append(i)
	return cells_to_reveal 

func show_mines():
	for mine in mine_coords:
		if is_mine(mine):
			erase_cell(grass_layer,mine)

func show_clues():
	for clue in clues_coords:
		if is_clue(clue):
			erase_cell(grass_layer,clue)
			
			
func _process(_delta):
	highlight_cell()
	

func highlight_cell():
	var mouse_pos := local_to_map(get_local_mouse_position())
	#clear hover tiles and add fresh one under the mouse
	clear_layer(hover_layer)
	#hover over grass cells 
	if is_grass(mouse_pos):
		set_cell(hover_layer,mouse_pos,tile_id,hover_atlas)
	else:
		#if the cell is cleared then only hover over number cell
		if is_number(mouse_pos):
			set_cell(hover_layer,mouse_pos,tile_id,hover_atlas)


#helper functions
func is_mine(pos):
	return get_cell_source_id(mine_layer,pos) != -1 

func is_clue(pos):
	return get_cell_source_id(clue_layer,pos) != -1 

func is_grass(pos):
	return get_cell_source_id(grass_layer,pos) != -1 

func is_number(pos):
	return get_cell_source_id(number_layer,pos) != -1 
	
func is_flag(pos):
	return get_cell_source_id(flag_layer,pos) != -1 

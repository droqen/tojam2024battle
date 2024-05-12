extends Node

const BLOCK = preload("res://gameplay/basic_block.tscn")
const BLOCK2 = preload("res://gameplay/breakable_block.tscn")
@onready var w = get_parent()
var spawn_locations = []
var world_width = GameGrid.world_width
var world_height = GameGrid.world_height
var level = {}  # Dictionary to hold block positions
func _ready():
	if NetworkManager.host:
		generate_maze()
		
			
		GameGrid.SetGridJson()

var spawn_clear_radius = 3

func ensure_clear_spawn_areas():
	for spawn_loc in spawn_locations:
		for x in range(spawn_loc.x - spawn_clear_radius, spawn_loc.x + spawn_clear_radius + 1):
			for y in range(spawn_loc.y - spawn_clear_radius, spawn_loc.y + spawn_clear_radius + 1):
				if Vector2(x, y) in level and level[Vector2(x, y)] == "destructible":
					level[Vector2(x, y)] = "empty"

# Grid to hold maze structure
var grid = []
func generate_maze():
	var spawnLoc1 = Vector2(-world_width + 1, -world_height + 1)
	var spawnLoc2 = Vector2(world_width - 1, -world_height + 1)
	var spawnLoc3 = Vector2(-world_width + 1, world_height - 1)
	var spawnLoc4 = Vector2(world_width - 1, world_height - 1)
	
	spawn_locations.append(spawnLoc1)
	spawn_locations.append(spawnLoc2)
	spawn_locations.append(spawnLoc3)
	spawn_locations.append(spawnLoc4)
	# Initialize grid with walls
	grid = []
	for x in range(-world_width, world_width + 1):
		var row = []
		for y in range(-world_height, world_height + 1):
			row.append(true)  # True means a wall is present
		grid.append(row)

	# Start carving from a random point
	var start_x = 0
	var start_y = 0
	carve_passages_from(Vector2(start_x, start_y))

	# Convert grid to level layout
	convert_grid_to_level()
	ensure_clear_spawn_areas()
	# Place blocks in the scene
	place_blocks()
	
var directions = [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]
func carve_passages_from(current_pos: Vector2):
	var direction_order = directions.duplicate()
	direction_order.shuffle()  # Randomize direction order

	for direction in direction_order:
		var next_pos = current_pos + direction * 2

		if is_within_bounds(next_pos) and grid[next_pos.x][next_pos.y]:
			grid[current_pos.x + direction.x][current_pos.y + direction.y] = false  # Remove wall
			grid[next_pos.x][next_pos.y] = false  # Carve passage
			carve_passages_from(next_pos)

func is_within_bounds(pos: Vector2) -> bool:
	return pos.x > -world_width and pos.x < world_width and pos.y > -world_height and pos.y < world_height
func place_blocks():
	for pos in level:
		if level[pos] == "solid":
			spawn_block_at(pos.x, pos.y)
		elif level[pos] == "destructible":
			spawn_block2_at(pos.x, pos.y)
func convert_grid_to_level():
	level.clear()
	for x in range(-world_width, world_width + 1):
		for y in range(-world_height, world_height + 1):
			if grid[x][y]:
				level[Vector2(x, y)] = "solid"
			else:
				level[Vector2(x, y)] = "empty"
			if randf() < 0.2 and y != -world_height and y != world_height and x != -world_width and x != world_width:
				level[Vector2(x, y)] = "destructible"


func spawn_block_at(x,y):
				var block = BLOCK.instantiate().setup(w, Vector2(x,y), GridObject.Type.wall)
func spawn_block2_at(x,y):
				var block = BLOCK2.instantiate().setup(w, Vector2(x,y), GridObject.Type.breakable)

func SetUpBlocks():
	for block in GameGrid.gridJson:
		if block[1] == GridObject.Type.wall:
			BLOCK.instantiate().setup(w, block[0], GridObject.Type.wall)
		elif block[1] == GridObject.Type.breakable:
			BLOCK2.instantiate().setup(w, block[0], GridObject.Type.breakable)

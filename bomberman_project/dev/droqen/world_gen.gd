extends Node

const BLOCK = preload("res://gameplay/basic_block.tscn")
const BLOCK2 = preload("res://gameplay/breakable_block.tscn")
@onready var w = get_parent()
@onready var world_width : int = 13
@onready var world_height : int = 9
var level = {}  # Dictionary to hold block positions
func _ready():
	if NetworkManager.host:
		level.clear()
		for x in range(-world_width, world_width + 1):
			for y in range(-world_height, world_height + 1):
				var solid: int = 0

				# Check if the position should have a solid block based on x and y coordinates
				if posmod(x, 2) == 1:
					solid += 1
				if posmod(y, 2) == 1:
					solid += 1

				# Ensure the border is always solid
				if abs(x) == world_width or abs(y) == world_height:
					solid = 2

				# Decide the block type
				if solid == 2 or (solid == 1 and randf() < 0.15):  # Slightly reduced chance for solid
					level[Vector2(x, y)] = "solid"
				elif randf() < 0.35 and (x != 0 or y != 0):  # Increased chance for destructible
					level[Vector2(x, y)] = "destructible"
				else:
					level[Vector2(x, y)] = "empty"

		# Ensure corners are open
		level[Vector2(-world_width + 1, -world_height + 1)] = "empty"
		level[Vector2(world_width - 1, -world_height + 1)] = "empty"
		level[Vector2(-world_width + 1, world_height - 1)] = "empty"
		level[Vector2(world_width - 1, world_height - 1)] = "empty"

		# Ensure no enclosed solid blocks
		ensure_no_enclosed_blocks()


		# Place blocks in the scene
		for pos in level:
			if level[pos] == "solid":
				spawn_block_at(pos.x, pos.y)
			elif level[pos] == "destructible":
				spawn_block2_at(pos.x, pos.y)
			
			
		GameGrid.SetGridJson()


func ensure_no_enclosed_blocks():
	for x in range(-world_width + 1, world_width):
		for y in range(-world_height + 1, world_height):
			if level.get(Vector2(x, y)) == "solid":
				if is_enclosed(Vector2(x, y)):
					level[Vector2(x, y)] = "destructible"  # Convert to destructible to break enclosure

# Function to check if a block is enclosed by solids
func is_enclosed(pos):
	return (
		level.get(Vector2(pos.x - 1, pos.y)) == "solid" and
		level.get(Vector2(pos.x + 1, pos.y)) == "solid" and
		level.get(Vector2(pos.x, pos.y - 1)) == "solid" and
		level.get(Vector2(pos.x, pos.y + 1)) == "solid"
	)

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

extends Node

const BLOCK = preload("res://gameplay/basic_block.tscn")
const BLOCK2 = preload("res://gameplay/breakable_block.tscn")
@onready var w = get_parent()
@onready var world_width : int = 13
@onready var world_height : int = 9

func _ready():
	if NetworkManager.host:
		for x in range(-world_width,world_width+1):
			for y in range(-world_height,world_height+1):
				var solid : int = 0
				if posmod(x, 2) == 1: solid += 1
				if posmod(y, 2) == 1: solid += 1
				if abs(x)==world_width or abs(y)==world_height: solid = 2
				if solid == 2 or (solid == 1 and randf() < 0.25):
					spawn_block_at(x,y)
				elif randf() < 0.1 and (x!=0 or y!=0):
					spawn_block2_at(x,y)
	else:
		print("get blocks")

func spawn_block_at(x,y):
				var block = BLOCK.instantiate().setup(w, Vector2(x,y))
func spawn_block2_at(x,y):
				var block = BLOCK2.instantiate().setup(w, Vector2(x,y))


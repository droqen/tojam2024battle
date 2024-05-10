extends Node

const BLOCK = preload("res://gameplay/basic_block.tscn")
onready var w = get_parent()
onready var world_width : int = 13
onready var world_height : int = 9

func _ready():
	for x in range(-world_width,world_width+1):
		for y in range(-world_height,world_height+1):
			var solid : int = 0
			if posmod(x, 2) == 1: solid += 1
			if posmod(y, 2) == 1: solid += 1
			if abs(x)==world_width or abs(y)==world_height: solid = 2
			if solid == 2 or (solid == 1 and randf() < 0.25):
				spawn_block_at(x,y)

func spawn_block_at(x,y):
				var block = BLOCK.instance()
				block.set_cell(Vector2(x,y))
				yield(get_tree(),"idle_frame")
				w.add_child(block)
				block.owner = owner if owner else self

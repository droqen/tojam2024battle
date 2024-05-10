extends Node

const BLOCK = preload("res://gameplay/basic_block.tscn")
onready var w = get_parent()

func _ready():
	for x in range(-10,10+1):
		for y in range(-10,10+1):
			var solid : int = 0
			if posmod(x, 2) == 1: solid += 1
			if posmod(y, 2) == 1: solid += 1
			if abs(x)==10 or abs(y)==10: solid = 2
			if solid == 2 or (solid == 1 and randf() < 0.25):
				spawn_block_at(x,y)

func spawn_block_at(x,y):
				var block = BLOCK.instance()
				block.set_cell(Vector2(x,y))
				yield(get_tree(),"idle_frame")
				w.add_child(block)
				block.owner = owner if owner else self

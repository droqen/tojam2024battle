extends GridObject

const IS_BOMB = true

const EXPLOSION_ROD = preload("res://scene/subsystems/explosion_rod.tscn")

var timer : int = 100
var maxreach : int = 3
var detonated : bool = false

func _physics_process(_delta):
	if timer > 0:
		timer -= 1
	elif not detonated:
		detonate()
func exploded():
	if timer > 5: timer = 5
func detonate():
	if detonated:
		queue_free() # just in case
		return
	else:
		timer = 0
		detonated = true
		var explosion_rays = [
			[cell, Vector2.LEFT],
			[cell, Vector2.RIGHT],
			[cell, Vector2.UP],
			[cell, Vector2.DOWN],
		]
		for i in range(4):
			var cell2 : Vector2 = explosion_rays[i][0]
			var dir : Vector2 = explosion_rays[i][1]
			for _r in range(maxreach):
				if GameGrid.is_wall(cell2 + dir):
					break
				else:
					cell2 += dir
					for obj in GameGrid.find_objs_at_cell(cell2):
						if obj.has_method('exploded'): obj.call('exploded')
			explosion_rays[i][0] = cell2
		EXPLOSION_ROD.instance().setup(get_parent(), explosion_rays[0][0], explosion_rays[1][0])
		EXPLOSION_ROD.instance().setup(get_parent(), explosion_rays[2][0], explosion_rays[3][0])
		queue_free()

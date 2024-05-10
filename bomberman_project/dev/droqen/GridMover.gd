extends GridObject
class_name GridMover

var goalfacedir : Vector3 = Vector3.RIGHT

func _physics_process(_delta):
	super._physics_process(_delta)
	$looktarget.position = lerp($looktarget.position, goalfacedir, 0.40)
	look_at(position + $looktarget.position, Vector3.UP)
#	look_at_from_position(Vector3.ZERO, $looktarget.translation, Vector3.UP)
	
	$Node/column.position = goalpos

func try_move(dir):
	if dir:
		goalfacedir = GameGrid.cell_to_pos(dir)
		if super.try_move(dir):
			return true
		else:
			self.velocity += GameGrid.cell_to_pos(dir) * 0.25
			return false
	else:
		return false

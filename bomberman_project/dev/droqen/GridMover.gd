extends GridObject
class_name GridMover

var goalfacedir : Vector3 = Vector3.RIGHT

func _physics_process(_delta):
	
	$looktarget.translation = lerp($looktarget.translation, goalfacedir, 0.40)
	look_at_from_position(Vector3.ZERO, $looktarget.translation, Vector3.UP)
	
	$Node/column.translation = goalpos

func try_move(dir):
	if dir:
		goalfacedir = GameGrid.cell_to_pos(dir)
		if .try_move(dir):
			return true
		else:
			self.velocity += GameGrid.cell_to_pos(dir) * 0.45
			return false
	else:
		return false

extends Spatial
class_name GridObject

var goalpos : Vector3
var cell : Vector2

func _enter_tree():
	GameGrid.reg(self)
func _exit_tree():
	GameGrid.unreg(self)
func set_cell(_cell):
	cell = _cell
	goalpos = GameGrid.cell_to_pos(cell)
func _physics_process(_delta):
	translation = lerp(translation, goalpos, 0.25)

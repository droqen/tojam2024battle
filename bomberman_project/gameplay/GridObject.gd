extends Spatial
class_name GridObject

var goalpos : Vector3
var cell : Vector2

var velocity : Vector3

var just_entered : bool = false

export (float) var maxspeed : float = 10.0
export (float) var accellerp : float = 0.1

func setup(parent, cell):
	yield(parent.get_tree(),"idle_frame")
	set_cell(cell)
	parent.add_child(self)
	owner = parent.owner
	return self

func _enter_tree():
	GameGrid.reg(self)
	just_entered = true
	
func _exit_tree():
	GameGrid.unreg(self)
	
func set_cell(_cell):
	cell = _cell
	goalpos = GameGrid.cell_to_pos(cell)
	if just_entered or not get_parent():
		translation = goalpos + Vector3.UP * rand_range(1,4)
		velocity.y = rand_range(0.1,0.2)
func try_move(dir) -> bool:
	var cell2 = cell + dir
	if GameGrid.find_objs_at_cell(cell2):
		return false
	else:
		set_cell(cell2)
		return true
func _physics_process(_delta):
	just_entered = false
	velocity.x = lerp(velocity.x, (goalpos-translation).x, 0.15)
	velocity.z = lerp(velocity.z, (goalpos-translation).z, 0.15)
	if translation.y > 0:
		velocity.y -= 0.02
	else:
		translation.y = 0
		if velocity.y < -0.02:
			velocity.y *= -0.5
		else:
			velocity.y = 0.0
#	velocity = lerp(velocity, (goalpos-translation) * 10.0, 0.1)
	translation += velocity

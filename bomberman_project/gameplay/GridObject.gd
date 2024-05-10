extends Node3D
class_name GridObject

var goalpos : Vector3
var cell : Vector2

var velocity : Vector3
var floorheight : float = 0.0

var just_entered : bool = false

@export var maxspeed : float = 10.0
@export var accellerp : float = 0.1

func setup(parent, cell):
	set_cell(cell)
	(func():
		parent.add_child(self)
		owner = parent.owner
	).call_deferred()
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
		position = goalpos + Vector3.UP * randf_range(1,4)
		velocity.y = randf_range(0.1,0.2)
func try_move(dir) -> bool:
	var cell2 = cell + dir
	if GameGrid.find_objs_at_cell(cell2):
		return false
	else:
		set_cell(cell2)
		return true
func _physics_process(_delta):
	just_entered = false
	var new_ground_velocity = lerp(velocity, (goalpos-position).limit_length(0.2)*2, 0.2)
	if (goalpos-position).length() < 0.2:
		new_ground_velocity *= 0.5
	velocity.x = new_ground_velocity.x
	velocity.z = new_ground_velocity.z
	if position.y > floorheight + 0.01 or velocity.y > 0:
		velocity.y -= 0.02
	else:
		position.y = floorheight
		if velocity.y < -0.04:
			velocity.y *= -0.5
		else:
			velocity.y = 0.0
#	velocity = lerp(velocity, (goalpos-translation) * 10.0, 0.1)
	position += velocity

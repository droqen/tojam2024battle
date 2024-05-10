extends GridMover
class_name PlayerMover

const IS_EXPLODABLE : bool = true
func exploded():
	queue_free() # oof, ya dead

func _physics_process(_delta):
	var dpad = Vector2(
		(1 if Input.is_action_just_pressed("ui_right") else 0) - (1 if Input.is_action_just_pressed("ui_left") else 0),
		(1 if Input.is_action_just_pressed("ui_up") else 0) - (1 if Input.is_action_just_pressed("ui_down") else 0)
	)
	if dpad:
		self.try_move(dpad)
		self.velocity.y = 0.2
		self.floorheight = 0.0
	
	if Input.is_action_just_pressed("ui_accept"):
		drop_bomb()

const BOMB = preload("res://scene/subsystems/bomb.tscn")

func drop_bomb():
	for obj in GameGrid.find_objs_at_cell(cell):
		if obj != self:
			return false # drop failed
	var bomb = BOMB.instance().setup(get_parent(), cell)
	self.velocity.y = 0.2
	self.floorheight = 2.0
	return true # drop succeeded

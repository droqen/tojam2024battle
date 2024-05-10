extends GridObject

var goalfacedir : Vector3 = Vector3.RIGHT

func _physics_process(_delta):
	var dpad = Vector2(
		(1 if Input.is_action_just_pressed("ui_right") else 0) - (1 if Input.is_action_just_pressed("ui_left") else 0),
		(1 if Input.is_action_just_pressed("ui_up") else 0) - (1 if Input.is_action_just_pressed("ui_down") else 0)
	)
	if dpad:
		if self.try_move(dpad):
			pass
		else:
			translation += 0.5 * GameGrid.cell_to_pos(dpad)
	look_at(translation + goalfacedir, Vector3.UP)

func try_move(dir):
	if dir:
		goalfacedir = GameGrid.cell_to_pos(dir)
		if .try_move(dir):
			return true
		else:
			return false
	else:
		return false

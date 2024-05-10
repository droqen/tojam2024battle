extends GridObject

func _physics_process(_delta):
	var dpad = Vector2(
		(1 if Input.is_action_just_pressed("ui_right") else 0) - (1 if Input.is_action_just_pressed("ui_left") else 0),
		(1 if Input.is_action_just_pressed("ui_up") else 0) - (1 if Input.is_action_just_pressed("ui_down") else 0)
	)
	if dpad:
		self.set_cell(self.cell + dpad)

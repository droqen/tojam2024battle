extends "res://gameplay/PlayerMover.gd"

func get_inputs():
	var stick = Vector2(
		(1 if Input.is_action_pressed("p2_right") else 0) - (1 if Input.is_action_pressed("p2_left") else 0),
		(1 if Input.is_action_pressed("p2_up") else 0) - (1 if Input.is_action_pressed("p2_down") else 0)
	)
	if stick.y: stick.x = 0
	if self.velocity.y > 0.25 or self.position.y > self.floorheight + 0.25:
		stick *= 0
	var dpad = Vector2(
		(1 if Input.is_action_just_pressed("p2_right") else 0) - (1 if Input.is_action_just_pressed("p2_left") else 0),
		(1 if Input.is_action_just_pressed("p2_up") else 0) - (1 if Input.is_action_just_pressed("p2_down") else 0)
	)
	var bomb = Input.is_action_just_pressed("p2_bomb")
	return [stick, dpad, bomb]

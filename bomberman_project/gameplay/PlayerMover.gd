extends GridMover
class_name PlayerMover

func _physics_process(_delta):
	var dpad = Vector2(
		(1 if Input.is_action_just_pressed("ui_right") else 0) - (1 if Input.is_action_just_pressed("ui_left") else 0),
		(1 if Input.is_action_just_pressed("ui_up") else 0) - (1 if Input.is_action_just_pressed("ui_down") else 0)
	)
	if dpad:
		self.try_move(dpad)
	
	if Input.is_action_just_pressed("ui_accept"):
		drop_bomb()

const BOMB = preload("res://scene/subsystems/bomb.tscn")

func drop_bomb():
	var bomb = BOMB.instance().setup(get_parent(), cell)

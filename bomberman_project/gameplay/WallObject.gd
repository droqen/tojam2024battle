extends GridObject
class_name WallObject

const IS_WALL : bool = true

func first_placed():
	super.first_placed()
	velocity.y = randf_range(0.2,0.4)

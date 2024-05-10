extends GridObject
class_name BreakableWallObject

const IS_EXPLODABLE : bool = true
func exploded():
	queue_free()

func first_placed():
	super.first_placed()
	position.y += randf_range(1,2)
	velocity.y = randf_range(0.4,0.5)


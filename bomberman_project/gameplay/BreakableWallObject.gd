extends GridObject
class_name BreakableWallObject

const IS_EXPLODABLE : bool = true
func exploded():
	queue_free()


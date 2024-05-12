extends Node

var gridobjs = []

var gridJson = []

func _ready():
	pass # Replace with function body.
func reg(go):
	gridobjs.append(go)
func unreg(go):
	gridobjs.erase(go)

func cell_to_pos(cell):
	return 4 * Vector3(cell.x, 0, -cell.y)

func find_objs_at_cell(cell):
	var objs = []
	for obj in gridobjs:
		if obj.cell == cell:
			objs.append(obj)
	return objs

func is_wall(cell) -> bool:
	for obj in find_objs_at_cell(cell):
		if obj.get('IS_WALL'):
			return true
	return false
	
func SetGridJson():
	gridJson.clear()
	for obj in gridobjs:
		gridJson.append([obj.cell,obj.type])

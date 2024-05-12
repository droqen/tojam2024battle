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
		if is_instance_valid(obj):
			if obj.cell == cell:
				objs.append(obj)
	return objs

func is_wall(cell) -> bool:
	for obj in find_objs_at_cell(cell):
		if is_instance_valid(obj):
			if obj.get('IS_WALL'):
				return true
	return false
	
func SetGridJson():
	gridJson.clear()
	for obj in gridobjs:
		gridJson.append([obj.cell,obj.type])
		
const BOMB = preload("res://scene/subsystems/bomb.tscn")

func SetUpGridFromJson(json):
	gridJson = json
	var worldGen = get_node("/root/Main/Node3D/block_world/world_gen")
	worldGen.SetUpBlocks()
	
func drop_item(type,cell):
	if type == GridObject.Type.bomb:
		var bomb = BOMB.instantiate().setup(get_parent(), cell, GridObject.Type.bomb).setup_underground_lay()
		

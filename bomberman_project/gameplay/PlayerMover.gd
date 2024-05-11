extends GridMover
class_name PlayerMover

const IS_EXPLODABLE : bool = true
const IS_TRANSPARENT : bool = true
func exploded():
	queue_free() # oof, ya dead

var queued_dpad = null
var queued_bomb = false
var playerNum

@onready var network_manager = get_node("/root/Main")

func _ready():
	print(str(playerNum) + " fuck")

var inputs

func get_inputs():
	if !is_multiplayer_authority():
		return inputs
	else:
		var stick = Vector2(
			(1 if Input.is_action_pressed("ui_right") else 0) - (1 if Input.is_action_pressed("ui_left") else 0),
			(1 if Input.is_action_pressed("ui_up") else 0) - (1 if Input.is_action_pressed("ui_down") else 0)
		)
		if stick.y: stick.x = 0
		if self.velocity.y > 0.25 or self.position.y > self.floorheight + 0.25:
			stick *= 0
		var dpad = Vector2(
			(1 if Input.is_action_just_pressed("ui_right") else 0) - (1 if Input.is_action_just_pressed("ui_left") else 0),
			(1 if Input.is_action_just_pressed("ui_up") else 0) - (1 if Input.is_action_just_pressed("ui_down") else 0)
		)
		var bomb = Input.is_action_just_pressed("ui_accept")
		
		if bomb or dpad != Vector2.ZERO or stick != Vector2.ZERO:
			var packet_data = {
			'input': [playerNum, stick, dpad, bomb]
			}
			network_manager.send_p2p_packet(0, packet_data) # Broadcast to everyone
		
		return [stick, dpad, bomb]
	
	return [Vector2.ZERO, Vector2.ZERO, false]

func _physics_process(_delta):
	super._physics_process(_delta)
	
	
	
	var down_to_earth = self.velocity.y < 0.5 and self.position.y < self.floorheight + 0.5 and (position.distance_to(goalpos) < 1)
	
	var inputs = get_inputs()
	var stick : Vector2 = inputs[0]
	var dpad : Vector2 = inputs[1]
	var bomb : bool = inputs[2]
	if stick.y: stick.x = 0
	if self.velocity.y > 0.25 or self.position.y > self.floorheight + 0.25:
		stick *= 0
	
	if dpad and not queued_bomb:
		queued_dpad = dpad
	if queued_dpad and queued_dpad.y: queued_dpad.x = 0
	if bomb:
		queued_bomb = true
		queued_dpad = null
	if (queued_dpad or stick) and (down_to_earth or self.floorheight > 0.0):
			self.try_move(queued_dpad if queued_dpad else stick)
			queued_dpad = null
			#self.position.y = lerp(self.position.y, self.floorheight, 0.5)
			self.velocity.y = 0.36 * clampf(inverse_lerp(2.0, 0.0, self.floorheight),0.0,1.0)
			self.floorheight = 0.0
	if queued_bomb and (down_to_earth):
		drop_bomb()
		queued_bomb = false
		
	inputs = [Vector2.ZERO, Vector2.ZERO, false]#reset after used

const BOMB = preload("res://scene/subsystems/bomb.tscn")

func drop_bomb():
	for obj in GameGrid.find_objs_at_cell(cell):
		if obj != self:
			return false # drop failed
	var bomb = BOMB.instantiate().setup(get_parent(), cell).setup_underground_lay()
	self.velocity.y = 0.45
	self.floorheight = 2.0
	if self.position.y < self.floorheight:
		self.position.y = lerp(position.y,floorheight,0.5)
	return true # drop succeeded

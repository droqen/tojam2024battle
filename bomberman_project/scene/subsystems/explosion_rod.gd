extends Node3D

# visual effect only
var life : float = 1.0

func setup(parent, cell1, cell2):
	(func():
		parent.add_child(self)
		owner = parent.owner
	).call_deferred()
	position = Vector3.ZERO
	var pos1 : Vector3 = GameGrid.cell_to_pos(cell1)
	$rod_ball.position = pos1
	if cell1 == cell2:
		$rod_ball2.hide()
		$rod_core.hide()
	else:
		var pos2 : Vector3 = GameGrid.cell_to_pos(cell2)
		$rod_ball2.position = pos2
	#	$rod_core.hide()
		$rod_core.look_at_from_position(pos1, pos2, Vector3.UP)
		$rod_core.scale.z = pos1.distance_to(pos2) * 0.5
		$rod_core.position = lerp(pos1, pos2, 0.5)
	return self

func _physics_process(delta):
	life -= delta
	position.y -= 2 * delta
	if life < 0:queue_free()

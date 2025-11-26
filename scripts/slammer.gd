extends RigidBody2D

signal shot_finished

var dragging := false
var drag_anchor := Vector2.ZERO
var current_mouse := Vector2.ZERO

var max_stretch := 260
var power := 20
var settle_velocity := 8.0
var settle_time := 0.25
var settle_timer := 0.0
var default_rotation := 0.0
var can_drag := false

var shot_taken := false

var target_position: Vector2

func _ready():
	default_rotation = 0.0
	freeze_mode = 0
	gravity_scale = 0
	contact_monitor = true
	max_contacts_reported = 10

func reset_for_turn(player := 1):
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0	
	rotation = default_rotation
	gravity_scale = 0
	shot_taken = false

	@warning_ignore("int_as_enum_without_match", "int_as_enum_without_cast")
	freeze_mode = 0

	if player == 1:
		target_position = Vector2(256, 300)
	else:
		target_position = Vector2(832, 300)

	transform.origin = target_position
	sleeping = false
	dragging = false
	settle_timer = 0.0

func _input(event):
	if not can_drag:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if (event.position - global_position).length() < 50:
					dragging = true
					drag_anchor = global_position
					current_mouse = event.position
					@warning_ignore("int_as_enum_without_match", "int_as_enum_without_cast")
					freeze_mode = 1
					gravity_scale = 0
			else:
				if dragging:
					dragging = false
					@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
					freeze_mode = 0
					_shoot(event.position)
	elif event is InputEventMouseMotion:
		if dragging:
			current_mouse = event.position

func _integrate_forces(state):
	if dragging:
		var offset = current_mouse - drag_anchor
		if offset.length() > max_stretch:
			offset = offset.normalized() * max_stretch

		state.transform.origin = drag_anchor + offset
		$Line2D.points = [-offset, Vector2.ZERO]
		@warning_ignore("int_as_enum_without_match", "int_as_enum_without_cast")
		freeze_mode = 1
		linear_velocity = Vector2.ZERO
		angular_velocity = 0
		return
	else:
		$Line2D.points = []
		if not shot_taken:
			state.transform.origin = target_position
			@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
			freeze_mode = 1
		else:
			@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
			freeze_mode = 0

	if not shot_taken:
		state.transform = Transform2D(default_rotation, target_position)
		return

	# Detect slammer has settled
	if linear_velocity.length() < settle_velocity:
		settle_timer += state.step
		if settle_timer >= settle_time:
			shot_finished.emit()
			shot_taken = false
	else:
		settle_timer = 0.0

func _shoot(mouse_pos: Vector2):
	var dir = (drag_anchor - mouse_pos)
	dir = dir.normalized() * min(dir.length(), max_stretch) * power
	apply_impulse(dir)
	gravity_scale = 1
	@warning_ignore("int_as_enum_without_match", "int_as_enum_without_cast")
	freeze_mode = 2  # DISABLED
	
	shot_taken = true
	
#func _on_slammer_body_entered(body):
	#if body.is_in_group("pog"):
		#var stack = get_tree().get_root().find_child("PogStack", true, false)
		#if stack:
			#stack.loosen_stack()

func _on_body_entered(body):
	if body.is_in_group("pog"):
		var stack = get_tree().get_root().find_child("PogStack", true, false)
		if stack:
			stack.loosen_stack()

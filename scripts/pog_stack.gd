extends Node2D

signal stack_settled

@export var cap_scene = preload("res://scenes/pog.tscn")
@export var count := 14
@export var stack_position := Vector2(544, 640)
@export var cap_height := 12.0
@export var micro_pos := 1.5
@export var micro_rot := 3.0

var settle_velocity := 1.0
var settle_time := 0.1
var settle_timer := 0.0

func _ready():
	spawn_stack()

func spawn_stack():
	for i in range(count):
		var cap = cap_scene.instantiate()

		if cap is RigidBody2D:
			cap.linear_damp = 15

		var base_y = -i * (cap_height * 0.90)
		cap.global_position = stack_position + Vector2(0, base_y)

		# tiny imperfections
		cap.global_position += Vector2(
			randf_range(-micro_pos, micro_pos),
			randf_range(-micro_pos, micro_pos)
		)

		cap.rotation = deg_to_rad(randf_range(-micro_rot, micro_rot))



		add_child(cap)
		
func loosen_stack():
	for cap in get_children():
		if cap is RigidBody2D:
			cap.linear_damp = 12.0
	set_physics_process(true)
	settle_timer = 0.0

func _physics_process(delta):
	var all_settled = true
	for cap in get_children():
		if cap is RigidBody2D and cap.linear_velocity.length() > settle_velocity:
			all_settled = false
			break
	
	if all_settled:
		settle_timer += delta
		if settle_timer >= settle_time:
			stack_settled.emit()
			set_physics_process(false)
	else:
		settle_timer = 0.0

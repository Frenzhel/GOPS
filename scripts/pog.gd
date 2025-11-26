extends RigidBody2D

var was_face_up := true
var settle_timer := 0.0

func _physics_process(delta):
	var is_face_up_now: bool = abs(rotation_degrees) <= 100

	if linear_velocity.length() < 1 and abs(angular_velocity) < 1:
		settle_timer += delta

		if settle_timer > 0.5:
			if is_face_up_now != was_face_up:
				was_face_up = is_face_up_now
	else:
		settle_timer = 0.0

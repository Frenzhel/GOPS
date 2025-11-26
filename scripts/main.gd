extends Node

var current_player := 1
var waiting_for_shot := true
var waiting_for_stack := false
var score1 := 0
var score2 := 0
var flip_count := 0
var last_shooter := 1

@onready var slammer := $Slammer
@onready var pog_stack := $PogStack
@onready var player1_label := $CanvasLayer/Player1Score
@onready var player2_label := $CanvasLayer/Player2Score
@onready var flip_timer := $FlipTimer

func _ready():
	slammer.shot_finished.connect(_on_shot_finished)
	pog_stack.stack_settled.connect(_on_stack_settled)
	flip_timer.timeout.connect(_on_flip_timer_timeout)
	_start_turn()

func _on_shot_finished():
	print("Player", current_player, "shot the slammer")
	last_shooter = current_player
	waiting_for_shot = true
	slammer.can_drag = false
	waiting_for_stack = true
	pog_stack.loosen_stack()

func _next_turn():
	print("Next turn for Player", current_player)
	if waiting_for_shot:
		current_player = 2 if current_player == 1 else 1
		_start_turn()

func _on_stack_settled():
	if waiting_for_stack:
		waiting_for_stack = false
		# Start a timer to allow time for any remaining flips to be counted
		flip_timer.start(2.0)  # 2 second delay

func _on_flip_timer_timeout():
	# Bulk count flipped pogs that have settled and add to current player's score
	var flipped_count = 0
	for pog in pog_stack.get_children():
		# if pog.linear_velocity.length() < 1 and abs(pog.angular_velocity) < 1:  # Settled
			if abs(pog.rotation_degrees) > 100:  # Flipped if upside down
				flipped_count += 1
				pog.queue_free()
	if current_player == 1:
		score1 += flipped_count
	else:
		score2 += flipped_count
	print("Player 1 Score:", score1, "Player 2 Score:", score2, "Flips this turn:", flipped_count)
	if player1_label:
		player1_label.text = "Player 1: " + str(score1)
	if player2_label:
		player2_label.text = "Player 2: " + str(score2)
	_next_turn()

func _start_turn():
	print("Starting turn for Player", current_player)
	waiting_for_shot = false
	slammer.can_drag = true
	slammer.reset_for_turn(current_player)

extends Node

enum SlammerType { HEAVY, LIGHT, BALANCED }

var current_player := 1
var waiting_for_shot := true
var waiting_for_stack := false
var score1 := 0
var score2 := 0
var flip_count := 0
var last_shooter := 1
var wins1 := 0
var wins2 := 0
var current_round := 1
var max_rounds := 3
var stack_count := 0
var selected_slammer_type = preload("res://scripts/slammer.gd").SlammerType.BALANCED

@onready var slammer: RigidBody2D = $Slammer
@onready var pog_stack := $PogStack
@onready var player1_label := $CanvasLayer/Scores/Player1Score
@onready var player2_label := $CanvasLayer/Scores/Player2Score
@onready var flip_timer := $FlipTimer
@onready var game_over_panel := $CanvasLayer/Scores/GameOverPanel
@onready var winner_label := $CanvasLayer/Scores/GameOverPanel/WinnerLabel
@onready var play_again_button := $CanvasLayer/Scores/GameOverPanel/PlayAgainButton
@onready var return_to_menu_button := $CanvasLayer/Scores/GameOverPanel/ReturnToMenuButton
@onready var menu_panel := $CanvasLayer/Menu
@onready var play_button := $CanvasLayer/Menu/PlayButton
@onready var exit_button := $CanvasLayer/Menu/ExitButton
@onready var slammer_selection_panel := $CanvasLayer/SlammerSelection
@onready var game_heavy_button := $CanvasLayer/SlammerSelection/HeavyButton
@onready var game_light_button := $CanvasLayer/SlammerSelection/LightButton
@onready var game_balanced_button := $CanvasLayer/SlammerSelection/BalancedButton
@onready var player1_wins_label := $CanvasLayer/Scores/Player1Wins
@onready var player2_wins_label := $CanvasLayer/Scores/Player2Wins
@onready var current_round_label := $CanvasLayer/Scores/CurrentRound
@onready var stack_button := $CanvasLayer/SlammerSelection/StackButton

func _ready():
	slammer.shot_finished.connect(_on_shot_finished)
	pog_stack.stack_settled.connect(_on_stack_settled)
	flip_timer.timeout.connect(_on_flip_timer_timeout)
	play_button.pressed.connect(_on_play_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	game_heavy_button.pressed.connect(_on_heavy_pressed)
	game_light_button.pressed.connect(_on_light_pressed)
	game_balanced_button.pressed.connect(_on_balanced_pressed)
	stack_button.pressed.connect(_on_stack_pressed)
	play_again_button.pressed.connect(_on_play_again_pressed)
	return_to_menu_button.pressed.connect(_on_return_to_menu_pressed)
	menu_panel.visible = true
	player1_label.visible = false
	player2_label.visible = false
	player1_wins_label.visible = false
	player2_wins_label.visible = false
	current_round_label.visible = false
	pog_stack.visible = false
	slammer.visible = false
	slammer_selection_panel.visible = false
	selected_slammer_type = preload("res://scripts/slammer.gd").SlammerType.BALANCED

func _on_shot_finished():
	print("Player", current_player, "shot the slammer")
	last_shooter = current_player
	waiting_for_shot = true
	slammer.can_drag = false
	waiting_for_stack = true
	pog_stack.loosen_stack()
	slammer_selection_panel.visible = false

func _next_turn():
	print("Next turn for Player", current_player)
	if waiting_for_shot:
		current_player = 2 if current_player == 1 else 1
		_start_turn()

func _on_stack_settled():
	if waiting_for_stack:
		waiting_for_stack = false
		flip_timer.start(2.0)

func _on_flip_timer_timeout():
	var flipped_count = 0
	for pog in pog_stack.get_children():
			if abs(pog.rotation_degrees) > 100:
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
	if player1_wins_label:
		player1_wins_label.text = "Wins: " + str(wins1)
	if player2_wins_label:
		player2_wins_label.text = "Wins: " + str(wins2)

	if score1 > 7:
		if current_player == 1:
			wins1 += 1
		_end_round(1)
	elif score2 > 7:
		if current_player == 2:
			wins2 += 1
		_end_round(2)
	else:
		_next_turn()

func _start_turn():
	print("Starting turn for Player", current_player)
	waiting_for_shot = false
	slammer.can_drag = true
	slammer.reset_for_turn(current_player)
	slammer_selection_panel.visible = true

func _end_round(round_winner: int):
	print("Round", current_round, "won by Player", round_winner)
	current_round += 1
	
	if wins1 >= 2 or wins2 >= 2 or current_round > max_rounds:
		_show_series_over()
	else:
		_start_new_round()

func _start_new_round():
	score1 = 0
	score2 = 0
	current_player = 1
	waiting_for_shot = true
	waiting_for_stack = false
	last_shooter = 1
	stack_count = 0
	player1_label.text = "Player 1: 0"
	player2_label.text = "Player 2: 0"
	player1_wins_label.text = "Wins: " + str(wins1)
	player2_wins_label.text = "Wins: " + str(wins2)
	current_round_label.text = "Round: " + str(current_round)

	for pog in pog_stack.get_children():
		pog.queue_free()

	pog_stack.spawn_stack()

	_start_turn()

func _show_series_over():
	var series_winner = 1 if wins1 > wins2 else 2
	winner_label.text = "Player " + str(series_winner) + " Wins the Series!"
	game_over_panel.visible = true
	slammer.can_drag = false

func _show_game_over(winner: int):
	winner_label.text = "Player " + str(winner) + " Wins!"
	game_over_panel.visible = true
	slammer.can_drag = false

func _on_play_again_pressed():
	score1 = 0
	score2 = 0
	wins1 = 0
	wins2 = 0
	current_round = 1
	current_player = 1
	waiting_for_shot = true
	waiting_for_stack = false
	last_shooter = 1
	player1_label.text = "Player 1: 0"
	player2_label.text = "Player 2: 0"
	player1_wins_label.text = "Wins: 0"
	player2_wins_label.text = "Wins: 0"
	current_round_label.text = "Round: 1"
	game_over_panel.visible = false
	
	for pog in pog_stack.get_children():
		pog.queue_free()
		
	pog_stack.spawn_stack()
	
	_start_turn()

func _on_play_pressed():
	menu_panel.visible = false
	player1_label.visible = true
	player2_label.visible = true
	player1_wins_label.visible = true
	player2_wins_label.visible = true
	current_round_label.visible = true
	slammer.visible = true
	pog_stack.visible = true
	print("Selected slammer type: ", selected_slammer_type)
	slammer.set_slammer_type(selected_slammer_type)
	_start_turn()

func _on_exit_pressed():
	get_tree().quit()

func _on_return_to_menu_pressed():
	game_over_panel.visible = false
	menu_panel.visible = true
	player1_label.visible = false
	player2_label.visible = false
	player1_wins_label.visible = false
	player2_wins_label.visible = false
	current_round_label.visible = false
	# Reset game state
	score1 = 0
	score2 = 0
	wins1 = 0
	wins2 = 0
	current_round = 1
	current_player = 1
	waiting_for_shot = true
	waiting_for_stack = false
	last_shooter = 1
	player1_label.text = "Player 1: 0"
	player2_label.text = "Player 2: 0"
	player1_wins_label.text = "Wins: 0"
	player2_wins_label.text = "Wins: 0"
	current_round_label.text = "Round: 1"
	slammer.can_drag = false
	slammer.visible = false
	pog_stack.visible = false
	slammer_selection_panel.visible = false
	for pog in pog_stack.get_children():
		pog.queue_free()

func _on_heavy_pressed():
	selected_slammer_type = preload("res://scripts/slammer.gd").SlammerType.HEAVY
	slammer.set_slammer_type(selected_slammer_type)

func _on_light_pressed():
	selected_slammer_type = preload("res://scripts/slammer.gd").SlammerType.LIGHT
	slammer.set_slammer_type(selected_slammer_type)

func _on_balanced_pressed():
	selected_slammer_type = preload("res://scripts/slammer.gd").SlammerType.BALANCED
	slammer.set_slammer_type(selected_slammer_type)

func _on_stack_pressed():
	if stack_count < 2 and score1 < 8 and score2 < 8 and not waiting_for_shot:
		pog_stack.restack_unflipped()
		stack_count += 1
		print("Player", current_player, "restacked pogs. Stack count:", stack_count)

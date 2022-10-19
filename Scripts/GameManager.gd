extends Node

var score: int = 0
var highscore: int = 0

var snake_segments: Array = []

var snake_speed: int = 32

var segment_delay: int = 10

var segment_delay_time = 0

onready var snake_segment_scene = preload("res://Scenes/SnakeSegment.tscn")
onready var food_scene = preload("res://Scenes/Food.tscn")

onready var level_node = get_tree().get_root().get_node("Level")

onready var segment_label = level_node.get_node("UI").get_node("SegmentLabel")
onready var score_label = level_node.get_node("UI").get_node("ScoreLabel")
onready var start_label = level_node.get_node("TitleNode").get_node("StartLabel")
onready var title_label = level_node.get_node("TitleNode").get_node("TitleLabel")

onready var game_over_menu = level_node.get_node("GameOverNode").get_node("GameOverMenu")

onready var retry_button = game_over_menu.get_node("Button")

var segment_positions: Array = []

func _ready() -> void:
	snake_segments = get_tree().get_nodes_in_group("SnakeSegments")
	update_segment_label()
	update_score_label()
	
	segment_delay_time = segment_delay
	
	start_label.visible = true
	title_label.visible = true
	game_over_menu.visible = false
	get_tree().paused = true
	
	retry_button.connect("button_up", self, "retry_button_up")

func _process(delta: float) -> void:
	if (segment_delay_time > 0):
		segment_delay_time -= 1
	else:
		segment_delay_time = segment_delay
	
	segment_positions = []
	for segment in snake_segments:
		segment_positions.push_back(segment.position)
	
	if (game_over_menu.visible == true && Input.is_action_just_pressed("ui_accept")):
		reset()
	
	if (start_label.visible == true):
		if (Input.is_action_just_pressed("ui_up") || Input.is_action_just_pressed("ui_down") ||
		Input.is_action_just_pressed("ui_left") || Input.is_action_just_pressed("ui_right")):
			start_game()


func game_over() -> void:
	game_over_menu.visible = true
	get_tree().paused = true
	
	if (score > highscore):
		highscore = score
	
	game_over_menu.get_node("ScoreLabel").text = "Score: " + str(score)
	game_over_menu.get_node("HighscoreLabel").text = "Highscore: " + str(highscore)
	game_over_menu.get_node("SegmentsLabel").text = "(Segments: " + str(snake_segments.size()) + ")"
	
	print("Game Over!")

func reset() -> void:
	for segment in snake_segments:
		get_tree().get_root().get_node("Level").remove_child(segment)
		segment.queue_free()
	
	snake_segments.clear()
	segment_positions.clear()
	
	for n in 3:
		var segment = add_segment()
		if (n == 0):
			segment.position = Vector2(256, 256)
			segment.is_head = true
		elif (n == 1):
			segment.position = Vector2(224, 256)
		else:
			segment.position = Vector2(192, 256)
	
	game_over_menu.visible = false
	start_label.visible = true
	title_label.visible = true
	
	score = 0
	update_score_label()
	
	segment_delay = 10
	
	print("reset game!")

func start_game() -> void:
	get_tree().paused = false
	start_label.visible = false
	title_label.visible = false


func update_segment_label() -> void:
	segment_label.text = "Segments: " + str(snake_segments.size())

func update_score_label() -> void:
	score_label.text = "Score: " + str(score)


func eat_food() -> void:
	spawn_food()
	add_segment()
	
	if (segment_delay > 3 && score % 5 == 0):
		segment_delay -= 1

func spawn_food() -> void:
	randomize()
	var food_pos = Vector2(stepify(64 + (randi() % 896) + 1, 32), stepify(64 + (randi() % 480) + 1, 32))
	
	#if food position is the same as one of the snake's segments, generate new position
	while (segment_positions.has(food_pos)):
		food_pos = Vector2(stepify(64 + (randi() % 896) + 1, 32), stepify(64 + (randi() % 480) + 1, 32))
	
	var food_instance = food_scene.instance()
	get_tree().get_root().get_node("Level").add_child(food_instance)
	
	food_instance.position = food_pos

func add_segment() -> Area2D:
	var segment = snake_segment_scene.instance()
	get_tree().get_root().get_node("Level").add_child(segment)
	
	snake_segments.push_back(segment)
	
	segment.segment_index = snake_segments.size() - 1
	segment.is_head = false
	
	var last_segment = snake_segments[snake_segments.size() - 2]
	segment.last_segment = last_segment
	
	segment.position = last_segment.last_position
	
	score += 1
	
	update_segment_label()
	update_score_label()
	
	return segment

func retry_button_up() -> void:
	if (game_over_menu.visible == true):
		reset()

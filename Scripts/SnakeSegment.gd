extends Area2D

var last_position: Vector2 = Vector2.ZERO

var direction: Vector2 = Vector2.ZERO
var direction_input: Vector2 = Vector2.ZERO

export var segment_index: int = 0

var last_segment = null

export var is_head = true

func _ready() -> void:
	if (is_head):
		direction_input = Vector2.RIGHT
	
	if (!is_head):
		last_segment = GameManager.snake_segments[segment_index - 1]
	
	last_position = position

func _process(delta: float) -> void:
	if (!get_tree().paused):
		if (is_head):
			if (Input.is_action_just_pressed("ui_right")):
				direction_input = Vector2.RIGHT
			elif (Input.is_action_just_pressed("ui_left")):
				direction_input = Vector2.LEFT
			elif (Input.is_action_just_pressed("ui_up")):
				direction_input = Vector2.UP
			elif (Input.is_action_just_pressed("ui_down")):
				direction_input = Vector2.DOWN
			
			if (int(position.x) % 32 == 0 && int(position.y) % 32 == 0):
				if (direction != -direction_input):
					direction = direction_input
		
		if (GameManager.segment_delay_time <= 0):
			last_position = position
			if (is_head):
				position += direction * GameManager.snake_speed
			else:
				position = last_segment.last_position


func _on_SnakeSegment_area_entered(area: Area2D) -> void:
	if (area.is_in_group("Food")):
		area.free()
		GameManager.call_deferred("eat_food")
	elif (area.is_in_group("SnakeSegments") || area.is_in_group("Walls")):
		GameManager.game_over()

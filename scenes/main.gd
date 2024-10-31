extends Node

@export var obstacle_scene : PackedScene
@export var obstacle_speed := 6
@export var obstacle_y_min := 300.0
@export var obstacle_y_max := 800.0

var obstacles: Array[Node2D]
var upcoming_obstacles: Array[Node2D]
var best_score = SaveManager.best_score
var score: int = 0:
	set(new_score):
		score = new_score
		score_label.text = str(new_score)
		point_sound.play()

@onready var player := %Player
@onready var score_label := %ScoreLabel
@onready var title: TextureRect = %Title
@onready var timer: Timer = %Timer
@onready var pause_button: TextureButton = %PauseButton
@onready var background: Sprite2D = %Background
@onready var game_over_menu: Control = %GameOverMenu
@onready var point_sound: AudioStreamPlayer = $PointSound

func _ready() -> void:
	timer.wait_time = 6.0/obstacle_speed
	timer.timeout.connect(spawn_obstacle)
	pause_button.pressed.connect(_on_pause_pressed)
	player.state_changed.connect(_on_player_state_changed)
	pause_button.modulate.a = 0
	score_label.modulate.a = 0

func _physics_process(delta: float) -> void:
	if player.state in [player.States.READY, player.States.FLYING]:
		# Move obstacles to the left
		$Ground/TextureRect.position.x -= obstacle_speed*delta*60
		if $Ground/TextureRect.position.x <= -580: # EEeew ! Dirty.
			$Ground/TextureRect.position.x = -460
	if player.state == player.States.FLYING:
		for obstacle in obstacles:
			obstacle.position.x -= obstacle_speed*delta*60
		# Check if the player passed an obstacle
		var next_obstacle: Node2D = upcoming_obstacles.front()
		if next_obstacle and next_obstacle.position.x <= player.position.x:
			score += 1
			upcoming_obstacles.pop_front()
		clean_obstacles()

func clean_obstacles() -> void:
	var oldest_obstacle: Node2D = obstacles.front()
	if oldest_obstacle and oldest_obstacle.position.x < -500:
		obstacles.pop_front()
		oldest_obstacle.queue_free()

func spawn_obstacle() -> void:
	var new_obstacle = obstacle_scene.instantiate()
	background.add_sibling(new_obstacle)
	obstacles.append(new_obstacle)
	upcoming_obstacles.append(new_obstacle)
	new_obstacle.position.x = 1500.0
	new_obstacle.position.y = randf_range(obstacle_y_min, obstacle_y_max)

func _on_pause_pressed() -> void:
	get_tree().paused = !get_tree().paused

func _on_player_state_changed(new_state) -> void:
	var States = player.States
	#var pause_tween: Tween = create_tween()
	match new_state:
		States.FLYING:
			spawn_obstacle()
			create_tween().tween_property(pause_button, "modulate:a", 1.0, 0.2)
			create_tween().tween_property(score_label, "modulate:a", 1.0, 0.2)
			create_tween().tween_property(title, "modulate:a", 0.0, 0.2)
			create_tween().tween_property(
				title, "position:y", title.position.y-40, 0.2
			)
			timer.start()
		States.DEAD:
			timer.stop()
			create_tween().tween_property(pause_button, "modulate:a", 0.0, 0.2)
			create_tween().tween_property(score_label, "modulate:a", 0.0, 0.2)
			game_over_menu.appear(score, best_score)
			if score > best_score:
				SaveManager.best_score = score
		

extends Node

@export var obstacle_scene : PackedScene
@export var player_speed: float = 7.0
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
@onready var game_over_menu: Control = %GameOverMenu
@onready var point_sound: AudioStreamPlayer = %PointSound
@onready var camera: Camera2D = %Camera2D
@onready var ground_body: StaticBody2D = $GroundSB2D
@onready var background: Node2D = %Background

@onready var camera_player_offset = camera.position.x - player.position.x
@onready var States = player.States

func _ready() -> void:
	timer.wait_time = 7.0/player_speed
	timer.timeout.connect(spawn_obstacle)
	pause_button.pressed.connect(_on_pause_pressed)
	player.state_changed.connect(_on_player_state_changed)
	pause_button.modulate.a = 0
	score_label.modulate.a = 0

func _notification(what: int):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and player.state == States.FLYING:
		get_tree().paused = true

func _on_pause_pressed() -> void:
	get_tree().paused = !get_tree().paused

func _physics_process(delta: float) -> void:
	ground_body.position.x = player.position.x
	if player.state in [player.States.READY, player.States.FLYING]:
		player.position.x += player_speed*delta*60
		camera.position.x = player.position.x + camera_player_offset
	if player.state == player.States.FLYING:
		# Check if the player passed an obstacle
		var next_obstacle: Node2D = upcoming_obstacles.front()
		if next_obstacle and next_obstacle.position.x <= player.position.x:
			score += 1
			upcoming_obstacles.pop_front()
		clean_obstacles()

func clean_obstacles() -> void:
	var oldest_obstacle: Node2D = obstacles.front()
	if oldest_obstacle and oldest_obstacle.position.x - player.position.x < -1000.0:
		print("delete ", oldest_obstacle)
		obstacles.pop_front()
		oldest_obstacle.queue_free()

func spawn_obstacle() -> void:
	var new_obstacle = obstacle_scene.instantiate()
	ground_body.add_sibling(new_obstacle)
	obstacles.append(new_obstacle)
	upcoming_obstacles.append(new_obstacle)
	new_obstacle.position.x = player.position.x + 1500.0
	new_obstacle.position.y = randf_range(obstacle_y_min, obstacle_y_max)
	new_obstacle.modulate.a = 0
	create_tween().tween_property(new_obstacle, "modulate:a", 1.0, 0.3)

func _on_player_state_changed(new_state) -> void:
	match new_state:
		States.FLYING:
			spawn_obstacle()
			create_tween().tween_property(pause_button, "modulate:a", 1.0, 0.2)
			create_tween().tween_property(score_label, "modulate:a", 1.0, 0.2)
			create_tween().tween_property(title, "modulate:a", 0.0, 0.2)
			create_tween().tween_property(title, "position:y", title.position.y-40, 0.2)
			timer.start()
		States.DEAD:
			timer.stop()
			create_tween().tween_property(pause_button, "modulate:a", 0.0, 0.2)
			create_tween().tween_property(score_label, "modulate:a", 0.0, 0.2)
			game_over_menu.appear(score, best_score)
			if score > best_score:
				SaveManager.best_score = score

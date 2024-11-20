extends Node

@export var debug: bool = false
@export var background_music: AudioStream
@export var pause_menu: PackedScene
@export var obstacle_scene: PackedScene
@export_category("Gameplay")
@export var player_speed: float = 7.0
@export var obstacle_y_min := 300.0
@export var obstacle_y_max := 800.0


var obstacles: Array[Node2D]
var upcoming_obstacles: Array[Node2D]
var score: int = 0:
	set(new_score):
		score = new_score
		score_label.text = str(new_score)
		point_sound.pitch_scale = 1.1
		if new_score % 10 == 0:
			point_sound.pitch_scale = 1.6
		point_sound.play()

var get_ready_textures = {
	"long": preload("res://assets/ui/titles/get_ready.png"),
	"short": preload("res://assets/ui/titles/get_ready_shorter.png")
}

@onready var player := %Player
@onready var score_label := %ScoreLabel
@onready var title: TextureRect = %Title
@onready var timer: Timer = %Timer
@onready var pause_button: Button = %PauseButton
@onready var game_over_menu: Control = %GameOverMenu
@onready var point_sound: AudioStreamPlayer = %PointSound
@onready var camera: Camera2D = %Camera2D
@onready var shaker_component2d: ShakerComponent2D = %ShakerComponent2D
@onready var ground_body: PhysicsBody2D = %GroundSB2D
@onready var flash: ColorRect = %Flash
@onready var best_score = SaveManager.best_score
@onready var camera_player_offset = camera.position.x - player.position.x
@onready var States = player.States

func _ready() -> void:
	timer.wait_time = 7.0 / player_speed
	timer.timeout.connect(spawn_obstacle)
	pause_button.pressed.connect(_on_pause_pressed)
	player.state_changed.connect(_on_player_state_changed)
	ResponsiveUI.ratio_changed.connect(_on_ratio_changed)
	_on_ratio_changed(ResponsiveUI.ratio)
	pause_button.visible = false
	pause_button.modulate.a = 0
	score_label.modulate.a = 0
	if debug and OS.is_debug_build():
		draw_debug_mobile()
	# Check if on android
	if OS.get_name() == "Android":
		# That's really not clean
		pause_button.offset_left *= 2
		pause_button.offset_top *= 2
		score_label.offset_right -= 3
		score_label.offset_top += 16

func draw_debug_mobile():
	var safe_area: Rect2i = DisplayServer.get_display_safe_area()
	var cutouts: Array[Rect2] = DisplayServer.get_display_cutouts()
	$UI/DebugCutouts.visible = true
	$UI/DebugSafeArea.visible = true
	$UI/DebugCutouts.text = "Cutouts: " + str(cutouts)
	$UI/DebugSafeArea.text = "Safe zone: " + str(safe_area)
	for rect in [safe_area] + cutouts:
		var debug_rect = ColorRect.new()
		debug_rect.color = Color(randf(), randf(), randf(), 0.3)
		debug_rect.position = rect.position
		debug_rect.size = rect.size
		debug_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$UI.add_child(debug_rect)

func _notification(what: int):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and player.state == States.FLYING:
		_on_pause_pressed()

func _on_pause_pressed() -> void:
	# SceneTree.paused is (un)set by the pause menu itself
	var pause_menu_instance = pause_menu.instantiate()
	pause_button.add_sibling(pause_menu_instance)
	pause_menu_instance.closed.connect(_on_pause_menu_closed)

func _on_pause_menu_closed() -> void:
	pass
	# Add countdown to resume. Maybe from the pause menu itself?

func _physics_process(delta: float) -> void:
	ground_body.position.x = player.position.x
	if player.state in [player.States.READY, player.States.FLYING]:
		player.position.x += player_speed * delta * 60
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
	new_obstacle.position.x = player.position.x + 2000.0
	new_obstacle.position.y = randf_range(obstacle_y_min, obstacle_y_max)
	new_obstacle.modulate.a = 0
	create_tween().tween_property(new_obstacle, "modulate:a", 1.0, 0.3)

func _on_ratio_changed(ratio) -> void:
	if ratio < 0.8:
		camera.zoom = Vector2(1.5, 1.5)
		pause_button.scale = Vector2(7.5, 7.5)
		score_label.scale = Vector2(15, 15)
		title.scale = Vector2(7.5, 7.5)
		title.texture = get_ready_textures["short"]
	else:
		camera.zoom = Vector2(1.0, 1.0)
		score_label.scale = Vector2(10, 10)
		pause_button.scale = Vector2(5, 5)
		title.scale = Vector2(5.0, 5.0)
		title.texture = get_ready_textures["long"]

func _on_player_state_changed(new_state) -> void:
	match new_state:
		States.FLYING:
			spawn_obstacle()
			pause_button.visible = true
			create_tween().tween_property(pause_button, "modulate:a", 1.0, 0.2)
			create_tween().tween_property(score_label, "modulate:a", 1.0, 0.2)
			create_tween().tween_property(title, "modulate:a", 0.0, 0.3)
			create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN).tween_property(title, "position:y", title.position.y - 90, 0.4)
			timer.start()
		States.DEAD:
			timer.stop()
			pause_button.disabled = true
			create_tween().tween_property(pause_button, "modulate:a", 0.0, 0.4)
			create_tween().tween_property(score_label, "modulate:a", 0.0, 0.4)
			shaker_component2d.play_shake()
			var flash_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT_IN)
			flash_tween.tween_property(flash, "color:a", 0.8, 0.1)
			flash_tween.tween_property(flash, "color:a", 0.0, 0.1)
			await get_tree().create_timer(0.8).timeout
			game_over_menu.appear(score, best_score)
			if score > best_score:
				SaveManager.best_score = score

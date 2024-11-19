extends Control

signal closed

@export var retry_scene: SceneChanger.MainScenes
@export var home_scene: SceneChanger.MainScenes
@export var settings: PackedScene

@onready var margin_container: MarginContainer = %MarginContainer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var close_button: TextureButton = %CloseButton
@onready var settings_button: Button = %SettingsButton
@onready var restart_button: Button = %RestartButton
@onready var home_button: Button = %HomeButton

@onready var buttons: Array = [settings_button, restart_button, home_button]
@onready var buttons_texts: Array = [settings_button, restart_button, home_button].map(
	func(button: Button) -> String: return button.text
)

func _ready() -> void:
	get_tree().paused = true
	close_button.pressed.connect(_on_close_pressed)
	settings_button.pressed.connect(func() -> void: add_child(settings.instantiate()))
	restart_button.pressed.connect(SceneChanger.change_to.bind(retry_scene))
	home_button.pressed.connect(SceneChanger.change_to.bind(home_scene))
	ResponsiveUI.ratio_changed.connect(_on_ratio_changed)
	_on_ratio_changed(ResponsiveUI.ratio)
	animation_player.play("appear")

func _exit_tree() -> void:
	get_tree().paused = false

func _on_close_pressed() -> void:
	animation_player.play_backwards("appear")
	await animation_player.animation_finished
	closed.emit()
	queue_free()

func _on_ratio_changed(ratio: float) -> void:
	if ratio < 0.8:
		margin_container.scale = Vector2(7.5, 7.5)
		margin_container.add_theme_constant_override("margin_left", 20)
		margin_container.add_theme_constant_override("margin_right", 20)
		for button in [settings_button, restart_button, home_button]:
			button.text = ""
	else:
		margin_container.scale = Vector2(5, 5)
		margin_container.add_theme_constant_override("margin_left", 0)
		margin_container.add_theme_constant_override("margin_right", 0)
		for i in range(buttons.size()):
			buttons[i].text = buttons_texts[i]

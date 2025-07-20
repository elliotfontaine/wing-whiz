extends Control

signal closed

@onready var margin_container: MarginContainer = %MarginContainer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var close_button: TextureButton = %CloseButton

func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	ResponsiveUI.ratio_changed.connect(_on_ratio_changed)
	_on_ratio_changed(ResponsiveUI.ratio)
	animation_player.play("appear")

func _on_close_pressed() -> void:
	animation_player.play_backwards("appear")
	await animation_player.animation_finished
	closed.emit()
	queue_free()

func _on_ratio_changed(ratio: float) -> void:
	if ratio < 0.8:
		margin_container.scale = Vector2(7.0, 7.0)
		margin_container.add_theme_constant_override("margin_left", 20)
		margin_container.add_theme_constant_override("margin_right", 20)
	else:
		margin_container.scale = Vector2(5, 5)
		margin_container.add_theme_constant_override("margin_left", 0)
		margin_container.add_theme_constant_override("margin_right", 0)

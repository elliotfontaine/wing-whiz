extends Control

const TAB_ICONS := {
	"audio": preload("res://assets/ui/icons/sound_icon.png"),
	"account": preload("res://assets/ui/icons/person_icon.png"),
}

@onready var margin_container: MarginContainer = %MarginContainer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var tab_container: TabContainer = %TabContainer
@onready var close_button_1: TextureButton = %CloseButton1
@onready var close_button_2: TextureButton = %CloseButton2
@onready var global: Label = %Global
@onready var music: Label = %Music
@onready var sfx: Label = %SFX


func _ready() -> void:
	tab_container.set_tab_icon(0, TAB_ICONS.audio)
	tab_container.set_tab_title(0, "")
	tab_container.set_tab_tooltip(0, "Audio")
	tab_container.set_tab_icon(1, TAB_ICONS.account)
	tab_container.set_tab_title(1, "")
	tab_container.set_tab_tooltip(1, "Account")
	close_button_1.pressed.connect(_on_close_pressed)
	close_button_2.pressed.connect(_on_close_pressed)
	ResponsiveUI.ratio_changed.connect(_on_ratio_changed)
	_on_ratio_changed(ResponsiveUI.ratio)
	animation_player.play("appear")


func _on_close_pressed() -> void:
	animation_player.play_backwards("appear")
	await animation_player.animation_finished
	queue_free()

func _on_ratio_changed(ratio: float) -> void:
	if ratio < 0.8:
		margin_container.scale = Vector2(7.5, 7.5)
		margin_container.add_theme_constant_override("margin_left", 35)
		margin_container.add_theme_constant_override("margin_right", 35)
		global.visible = false
		music.visible = false
		sfx.visible = false
	else:
		margin_container.scale = Vector2(5, 5)
		margin_container.add_theme_constant_override("margin_left", 0)
		margin_container.add_theme_constant_override("margin_right", 0)
		global.visible = true
		music.visible = true
		sfx.visible = true

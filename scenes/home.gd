extends Node

var play_scene: String = "res://scenes/main.tscn"

var game_title_textures = {
	"long": preload("res://assets/ui/titles/wing_whiz.png"),
	"short": preload("res://assets/ui/titles/wing_whiz_shorter.png")
}

@onready var player: CharacterBody2D = %Player
@onready var camera: Camera2D = %Camera2D
@onready var main_menu: PanelContainer = %MainMenu
@onready var play_button: Button = %PlayButton
@onready var title: TextureRect = %Title
@onready var camera_player_offset = camera.position.x - player.position.x

func _ready() -> void:
	play_button.pressed.connect(SceneChanger.change_to.bind(play_scene))
	ResponsiveUI.ratio_changed.connect(_on_ratio_changed)
	_on_ratio_changed(ResponsiveUI.ratio)
	player.state = player.States.AUTO

func _process(delta: float) -> void:
	player.position.x += 300 * delta
	camera.position.x = player.position.x + camera_player_offset

func _on_ratio_changed(ratio) -> void:
	if ratio < 0.8:
		camera.zoom = Vector2(1.5, 1.5)
		main_menu.scale = Vector2(7.5, 7.5)
		#score_label.scale = Vector2(15, 15)
		title.scale = Vector2(7.5, 7.5)
		title.texture = game_title_textures["short"]
	else:
		camera.zoom = Vector2(1.0, 1.0)
		main_menu.scale = Vector2(5, 5)
		title.scale = Vector2(5.0, 5.0)
		title.texture = game_title_textures["long"]
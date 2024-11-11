extends Node

var play_scene: String = "res://scenes/main.tscn"

@onready var player: CharacterBody2D = %Player
@onready var play_button: Button = %PlayButton
@onready var camera: Camera2D = %Camera2D
@onready var camera_player_offset = camera.position.x - player.position.x

func _ready() -> void:
	play_button.pressed.connect(SceneChanger.change_to.bind(play_scene))
	player.state = player.States.AUTO

func _process(delta: float) -> void:
	player.position.x += 300*delta
	camera.position.x = player.position.x + camera_player_offset

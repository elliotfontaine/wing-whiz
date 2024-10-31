extends Node

var play_scene: String = "res://scenes/main.tscn"

@onready var player: CharacterBody2D = %Player
@onready var play_button: TextureButton = %PlayButton

func _ready() -> void:
	play_button.pressed.connect(SceneChanger.change_to.bind(play_scene))
	player.state = player.States.AUTO
	# player.state_changed.connect(_on_player_state_changed)

func _process(delta: float) -> void:
	$Ground/TextureRect.position.x -= 4*delta*60
	if $Ground/TextureRect.position.x <= -580: # EEeew ! Dirty.
		$Ground/TextureRect.position.x = -460

#func _on_player_state_changed(new_state) -> void:
	#var States = player.States
	#if new_state == States.FLYING:
		#player.state = States.READY

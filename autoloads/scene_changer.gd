extends CanvasLayer

enum MainScenes {HOME, MAIN}

const _MAIN_SCENES_PATHS = {
	MainScenes.HOME: "res://scenes/home.tscn",
	MainScenes.MAIN: "res://scenes/main.tscn"
}

var _new_scene_path: String
var _startup_scene: String = ProjectSettings.get_setting("application/run/main_scene")

@onready var _animation_player: AnimationPlayer = %AnimationPlayer

## Interface to this autoload
func change_to(new_scene: MainScenes, transition: String = "fade_out_in") -> void:
	_new_scene_path = _MAIN_SCENES_PATHS[new_scene]
	if _animation_player.is_playing():
		_animation_player.stop()
	_animation_player.play(transition)

## Called by the AnimationPlayer
func _change_scene_deferred():
	get_tree().call_deferred("change_scene_to_file", _new_scene_path)
	

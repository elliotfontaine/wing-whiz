extends CanvasLayer

var _new_scene_path: String

@onready var _animation_player: AnimationPlayer = %AnimationPlayer

## Interface to this autoload
func change_to(new_scene_path: String) -> void:
	print("changing to:", new_scene_path)
	_new_scene_path = new_scene_path
	if _animation_player.is_playing():
		_animation_player.stop()
	_animation_player.play("fade_out_in")

## Called by the AnimationPlayer
func _change_scene_deferred():
	get_tree().call_deferred("change_scene_to_file", _new_scene_path)
	

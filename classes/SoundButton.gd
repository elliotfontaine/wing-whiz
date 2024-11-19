extends Button
class_name SoundButton

@export var sound: AudioStream = preload("res://assets/audio/sfx/rollover2.ogg")

@onready var sound_player := AudioStreamPlayer.new()

func _ready():
	mouse_default_cursor_shape = CursorShape.CURSOR_POINTING_HAND
	sound_player.stream = sound
	sound_player.bus = "SFX"
	add_child(sound_player)
	pressed.connect(sound_player.play)
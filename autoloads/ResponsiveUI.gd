extends Node

signal ratio_changed(new_ratio)

const TARGET_WIDTH: float = 960.0
const TARGET_HEIGHT: float = 1280.0

var ratio: float = 1.0

func _ready() -> void:
    get_tree().get_root().size_changed.connect(_on_viewport_resized)
    _update_ratio()

func _on_viewport_resized() -> void:
    _update_ratio()

func _update_ratio() -> void:
    ratio = (DisplayServer.window_get_size().x / TARGET_WIDTH) / (DisplayServer.window_get_size().y / TARGET_HEIGHT)
    ratio_changed.emit(ratio)
    print_debug("New viewport: " + str(DisplayServer.window_get_size()) + ". Ratio: " + str(ratio))
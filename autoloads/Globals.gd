extends Node

const GAME_VERSION := "0.1.0"
const SAVEFILE_VERSION := "1"
const GITHUB_URL := "https://github.com/elliotfontaine/wing-whiz"
const ITCHIO_URL := "placeholder_itch.io_url"

var GAME_NAME: String = ProjectSettings.get_setting("application/config/name")
var TARGET_HEIGHT: int = ProjectSettings.get_setting("display/window/size/viewport_height")
var TARGET_WIDTH: int = ProjectSettings.get_setting("display/window/size/viewport_width")


func _ready() -> void:
    pass
	#OS.request_permissions()

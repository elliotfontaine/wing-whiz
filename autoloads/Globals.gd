extends Node

const GAME_VERSION := "0.1.0"
const SAVEFILE_VERSION := "1"
const GITHUB_URL := "https://github.com/elliotfontaine/wing-whiz"
const ITCHIO_URL := "placeholder_itch.io_url"

var GAME_NAME: String = ProjectSettings.get_setting("application/config/name")
var TARGET_HEIGHT: int = ProjectSettings.get_setting("display/window/size/viewport_height")
var TARGET_WIDTH: int = ProjectSettings.get_setting("display/window/size/viewport_width")


func _ready() -> void:
    #OS.request_permissions()

    # SilentWolf plugin configuration
    SilentWolf.configure({
        "api_key": "itg02Lw5RS3Iva1wzR6j64n9VU0b00Yn8tgZll8a",
        "game_id": "WingWhiz",
        "log_level": 2,
        "game_version": GAME_VERSION,
    })
    SilentWolf.configure_auth({
        "redirect_to_scene": "res://scenes/Home.tscn",
        "login_scene": "res://addons/silent_wolf/Auth/Login.tscn",
        "email_confirmation_scene": "res://addons/silent_wolf/Auth/ConfirmEmail.tscn",
        "reset_password_scene": "res://addons/silent_wolf/Auth/ResetPassword.tscn",
        "session_duration_seconds": 0,
        "saved_session_expiration_days": 365,
    })
    SilentWolf.configure_scores({"open_scene_on_close": "res://scenes/Home.tscn"})
    SilentWolf.Auth.auto_login_player()
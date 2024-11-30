extends VBoxContainer

signal login_succeeded

const SWLogger = preload("res://addons/silent_wolf/utils/SWLogger.gd")

@onready var username_line_edit: LineEdit = %UsernameLineEdit
@onready var password_line_edit: LineEdit = %PasswordLineEdit
@onready var login_button: Button = %LoginButton
@onready var processing_label: Label = %ProcessingLabel
@onready var error_message: Label = %ErrorMessage


func _ready():
	SilentWolf.Auth.sw_login_complete.connect(_on_login_complete)
	login_button.pressed.connect(_on_login_button_pressed)
	processing_label.hide()
	error_message.hide()

func _on_login_button_pressed() -> void:
	var username = username_line_edit.text
	var password = password_line_edit.text
	if username == "" or password == "":
		error_message.text = "Username and password are required."
		error_message.show()
		return
	SWLogger.debug("Login form submitted")
	SilentWolf.Auth.login_player(username, password, true)
	error_message.hide()
	processing_label.show()

func _on_login_complete(sw_result: Dictionary) -> void:
	if sw_result.success:
		login_succeeded.emit()
	else:
		login_failure(sw_result.error)

func login_failure(error: String) -> void:
	SWLogger.info("log in failed: " + str(error))
	error_message.text = error
	processing_label.hide()
	error_message.show()

func cleanup_form() -> void:
	processing_label.hide()
	error_message.hide()
	username_line_edit.text = ""
	password_line_edit.text = ""
	error_message.text = ""

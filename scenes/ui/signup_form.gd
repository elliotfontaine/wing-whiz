extends VBoxContainer

signal registration_succeeded

const SWLogger = preload("res://addons/silent_wolf/utils/SWLogger.gd")

var username: String:
	set(value): %UsernameLineEdit.text = value
	get: return %UsernameLineEdit.text
var password: String:
	set(value): %PasswordLineEdit.text = value
	get: return %PasswordLineEdit.text
var confirm_password: String:
	set(value): %ConfirmPasswordLineEdit.text = value
	get: return %ConfirmPasswordLineEdit.text

@onready var signup_button: Button = %SignupButton
@onready var processing_label: Label = %ProcessingLabel
@onready var error_message: Label = %ErrorMessage


func _ready():
	SilentWolf.Auth.sw_registration_complete.connect(_on_registration_complete)
	signup_button.pressed.connect(_on_signup_button_pressed)
	processing_label.hide()
	error_message.hide()

func _on_signup_button_pressed() -> void:
	if username == "" or password == "" or confirm_password == "":
		error_message.text = "All fields are required."
		error_message.show()
		return
	SWLogger.debug("Signup form submitted")
	SilentWolf.Auth.register_player(username, "noemail@required", password, confirm_password)
	error_message.hide()
	processing_label.show()

func _on_registration_complete(sw_result: Dictionary) -> void:
	if sw_result.success:
		registration_succeeded.emit()
	else:
		signup_failure(sw_result.error)

func signup_failure(error: String) -> void:
	SWLogger.info("Registration failed: " + str(error))
	error_message.text = error
	processing_label.hide()
	error_message.show()

func cleanup_form() -> void:
	processing_label.hide()
	error_message.hide()
	username = ""
	password = ""
	confirm_password = ""
	error_message.text = ""

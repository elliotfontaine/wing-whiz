extends VBoxContainer

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
	signup_button.pressed.connect(_on_signup_button_pressed)
	processing_label.hide()
	error_message.hide()

func _on_signup_button_pressed() -> void:
	if username == "" or password == "" or confirm_password == "":
		error_message.text = "All fields are required."
		error_message.show()
		return
	if password != confirm_password:
		error_message.text = "Passwords do not match."
		error_message.show()
		return
	error_message.hide()
	processing_label.show()
	var res = await Talo.player_auth.register(username, password, "noemail@required.io", false)
	if res == FAILED:
		signup_failure()

func signup_failure() -> void:
	processing_label.hide()
	error_message.show()
	match Talo.player_auth.last_error.get_code():
		TaloAuthError.ErrorCode.IDENTIFIER_TAKEN:
			error_message.text = "Username is already taken"
		_:
			error_message.text = Talo.player_auth.last_error.get_string()

func cleanup_form() -> void:
	processing_label.hide()
	error_message.hide()
	username = ""
	password = ""
	confirm_password = ""
	error_message.text = ""
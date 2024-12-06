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
var error_message: String:
	set(value):
		if value == "":
			%ErrorLabel.hide()
		else:
			%ErrorLabel.text = value
			processing_label.hide()
			%ErrorLabel.show()
	get: return %ErrorLabel.text

@onready var signup_button: Button = %SignupButton
@onready var processing_label: Label = %ProcessingLabel
@onready var error_label: Label = %ErrorLabel


func _ready():
	cleanup_form()
	signup_button.pressed.connect(_on_signup_button_pressed)
	processing_label.visibility_changed.connect(func(): if processing_label.visible: error_label.hide())

func _on_signup_button_pressed() -> void:
	if username == "" or password == "" or confirm_password == "":
		error_message = "All fields are required."
		return
	if password != confirm_password:
		error_message = "Passwords do not match."
		return
	signup_button.disabled = true
	processing_label.show()
	var res = await Talo.player_auth.register(username, password, "noemail@required.io", false)
	if res == FAILED:
		display_failure_code()
		signup_button.disabled = false

func display_failure_code() -> void:
	match Talo.player_auth.last_error.get_code():
		TaloAuthError.ErrorCode.IDENTIFIER_TAKEN:
			error_message = "Username is already taken"
		_:
			error_message = Talo.player_auth.last_error.get_string()

func cleanup_form() -> void:
	processing_label.hide()
	signup_button.disabled = false
	username = ""
	password = ""
	confirm_password = ""
	error_message = ""
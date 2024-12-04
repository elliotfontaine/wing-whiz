extends VBoxContainer

var username: String:
	set(value): %UsernameLineEdit.text = value
	get: return %UsernameLineEdit.text
var password: String:
	set(value): %PasswordLineEdit.text = value
	get: return %PasswordLineEdit.text

@onready var login_button: Button = %LoginButton
@onready var processing_label: Label = %ProcessingLabel
@onready var error_message: Label = %ErrorMessage


func _ready():
	login_button.pressed.connect(_on_login_button_pressed)
	processing_label.hide()
	error_message.hide()

func _on_login_button_pressed() -> void:
	if not username:
		error_message.text = "Username is required"
		return
	if not password:
		error_message.text = "Password is required"
		return
	error_message.hide()
	processing_label.show()
	var res = await Talo.player_auth.login(username, password)
	if res[0] == FAILED:
		login_failure()

func login_failure() -> void:
	processing_label.hide()
	error_message.show()
	match Talo.player_auth.last_error.get_code():
		TaloAuthError.ErrorCode.INVALID_CREDENTIALS:
			error_message.text = "Username or password is incorrect."
		_:
			error_message.text = Talo.player_auth.last_error.get_string()

func cleanup_form() -> void:
	processing_label.hide()
	error_message.hide()
	username = ""
	password = ""
	error_message.text = ""

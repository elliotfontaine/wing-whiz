extends VBoxContainer

var username: String:
	set(value): %UsernameLineEdit.text = value
	get: return %UsernameLineEdit.text
var password: String:
	set(value): %PasswordLineEdit.text = value
	get: return %PasswordLineEdit.text
var error_message: String:
	set(value):
		if value == "":
			%ErrorLabel.hide()
		else:
			%ErrorLabel.text = value
			processing_label.hide()
			%ErrorLabel.show()
	get: return %ErrorLabel.text

@onready var login_button: Button = %LoginButton
@onready var processing_label: Label = %ProcessingLabel
@onready var error_label: Label = %ErrorLabel


func _ready():
	cleanup_form()
	login_button.pressed.connect(_on_login_button_pressed)
	processing_label.visibility_changed.connect(func(): if processing_label.visible: error_label.hide())

func _on_login_button_pressed() -> void:
	if not username:
		error_message = "Username is required"
		return
	if not password:
		error_message = "Password is required"
		return
	login_button.disabled = true
	processing_label.show()
	var res = await Talo.player_auth.login(username, password)
	match res:
		Talo.player_auth.LoginResult.FAILED:
			display_failure_code()
			login_button.disabled = false
		Talo.player_auth.LoginResult.OK:
			pass

func display_failure_code() -> void:
	match Talo.player_auth.last_error.get_code():
		TaloAuthError.ErrorCode.INVALID_CREDENTIALS:
			error_message = "Username or password is incorrect."
		_:
			error_message = Talo.player_auth.last_error.get_string()

func cleanup_form() -> void:
	processing_label.hide()
	login_button.disabled = false
	username = ""
	password = ""
	error_message = ""

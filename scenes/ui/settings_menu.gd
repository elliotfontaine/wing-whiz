extends Control

signal logout_success

const TAB_ICONS := {
	"audio": preload("res://assets/ui/icons/sound_icon.png"),
	"account": preload("res://assets/ui/icons/person_icon.png"),
}

enum AccountTabs {
	PLAYER_CARD,
	LOG_IN,
	SIGN_UP,
}

@onready var margin_container: MarginContainer = %MarginContainer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var tab_container: TabContainer = %TabContainer
@onready var close_button_1: TextureButton = %CloseButton1
@onready var close_button_2: TextureButton = %CloseButton2
@onready var global: Label = %Global
@onready var music: Label = %Music
@onready var sfx: Label = %SFX

@onready var account_tab_container: TabContainer = %AccountTabContainer
@onready var login_form: VBoxContainer = %LoginForm
@onready var signup_form: VBoxContainer = %SignupForm
@onready var logout_button: Button = %LogoutButton
@onready var to_login_button: Button = %LoginButton
@onready var to_signup_button: Button = %SignupButton


func _ready() -> void:
	tab_container.set_tab_icon(0, TAB_ICONS.audio)
	tab_container.set_tab_title(0, "")
	tab_container.set_tab_icon(1, TAB_ICONS.account)
	tab_container.set_tab_title(1, "")
	close_button_1.pressed.connect(_on_close_pressed)
	close_button_2.pressed.connect(_on_close_pressed)
	tab_container.tab_changed.connect(_on_tab_changed)
	
	logout_button.pressed.connect(_on_logout_pressed)
	to_login_button.pressed.connect(_on_to_login_pressed)
	to_signup_button.pressed.connect(_on_to_signup_pressed)
	Talo.players.identified.connect(_on_player_identified)
	choose_account_tab()
	
	ResponsiveUI.ratio_changed.connect(_on_ratio_changed)
	_on_ratio_changed(ResponsiveUI.ratio)
	animation_player.play("appear")

func _on_close_pressed() -> void:
	animation_player.play_backwards("appear")
	await animation_player.animation_finished
	queue_free()

func _on_tab_changed(tab: int) -> void:
	if tab == 1:
		choose_account_tab()

func choose_account_tab() -> void:
	if Talo.identity_check(false) == OK:
		account_tab_container.current_tab = AccountTabs.PLAYER_CARD
		# TODO: Replace by a real playercard scene
		account_tab_container.find_child("UsernameDisplay", true).text = Talo.current_alias.identifier
	else:
		account_tab_container.current_tab = AccountTabs.LOG_IN

func _on_player_identified(_player) -> void:
	account_tab_container.current_tab = AccountTabs.PLAYER_CARD
	signup_form.cleanup_form()
	login_form.cleanup_form()
	# TODO: Replace by a real playercard scene
	account_tab_container.find_child("UsernameDisplay", true).text = Talo.current_alias.identifier

func _on_logout_pressed() -> void:
	await Talo.player_auth.logout()
	logout_success.emit()
	account_tab_container.current_tab = AccountTabs.LOG_IN

func _on_to_signup_pressed() -> void:
	account_tab_container.current_tab = AccountTabs.SIGN_UP
	signup_form.cleanup_form()
	signup_form.username = login_form.username
	signup_form.password = login_form.password

func _on_to_login_pressed() -> void:
	account_tab_container.current_tab = AccountTabs.LOG_IN
	login_form.cleanup_form()
	login_form.username = signup_form.username
	login_form.password = signup_form.password

func _on_ratio_changed(ratio: float) -> void:
	if ratio < 0.8:
		margin_container.scale = Vector2(7.0, 7.0)
		margin_container.add_theme_constant_override("margin_left", 30)
		margin_container.add_theme_constant_override("margin_right", 30)
		global.visible = false
		music.visible = false
		sfx.visible = false
	else:
		margin_container.scale = Vector2(5, 5)
		margin_container.add_theme_constant_override("margin_left", 0)
		margin_container.add_theme_constant_override("margin_right", 0)
		global.visible = true
		music.visible = true
		sfx.visible = true

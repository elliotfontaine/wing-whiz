extends Control

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
@onready var signup_form: Label = %Dummy # VBoxContainer = %SignupForm
@onready var logout_button: Button = %LogoutButton
@onready var login_button: Button = %LoginButton
@onready var signup_button: Button = %SignupButton


func _ready() -> void:
	tab_container.set_tab_icon(0, TAB_ICONS.audio)
	tab_container.set_tab_title(0, "")
	tab_container.set_tab_tooltip(0, "Audio")
	tab_container.set_tab_icon(1, TAB_ICONS.account)
	tab_container.set_tab_title(1, "")
	tab_container.set_tab_tooltip(1, "Account")
	close_button_1.pressed.connect(_on_close_pressed)
	close_button_2.pressed.connect(_on_close_pressed)

	choose_account_tab()
	tab_container.tab_changed.connect(_on_tab_changed)
	logout_button.pressed.connect(_on_logout_pressed)
	login_button.pressed.connect(
		func() -> void: account_tab_container.current_tab = AccountTabs.LOG_IN)
	signup_button.pressed.connect(
		func() -> void: account_tab_container.current_tab = AccountTabs.SIGN_UP)
	login_form.connect("login_succeeded", _on_login_succeeded)
	
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
	if SilentWolf.Auth.logged_in_player != null:
		account_tab_container.current_tab = AccountTabs.PLAYER_CARD
		account_tab_container.find_child("UsernameDisplay", true).text = SilentWolf.Auth.logged_in_player
	else:
		account_tab_container.current_tab = AccountTabs.LOG_IN


func _on_login_succeeded() -> void:
	account_tab_container.current_tab = AccountTabs.PLAYER_CARD
	account_tab_container.find_child("UsernameDisplay", true).text = SilentWolf.Auth.logged_in_player


func _on_logout_pressed() -> void:
	await SilentWolf.Auth.logout_player()
	login_form.cleanup_form()
	account_tab_container.current_tab = AccountTabs.LOG_IN


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

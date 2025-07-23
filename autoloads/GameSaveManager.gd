extends Node

enum SaveTypes {GUEST, AUTH}

const _GUEST_SAVE_PATH: String = "user://guest_save.ini"
const _AUTH_SAVE_PATH: String = "user://auth_save.ini"
const SAVE_PATHS: Dictionary = {SaveTypes.GUEST: _GUEST_SAVE_PATH, SaveTypes.AUTH: _AUTH_SAVE_PATH}

const _DEFAULT_GUEST_SAVE: String = "res://autoloads/default_guest_save.ini"
const _DEFAULT_AUTH_SAVE: String = "res://autoloads/default_auth_save.ini"

var current_save_type: SaveTypes
var current_save: ConfigFile

var username: String:
	get: return _username
	set(new):
		print_debug("You shouldn't try to manually set username")
		return

var _username: String:
	get: return _prop_getter("meta", "username")
	set(new): _prop_setter("meta", "username", new)

var highscore: int:
	get: return _prop_getter("progress", "highscore")
	set(new): _prop_setter("progress", "highscore", new, func(x): return x > highscore)

var coins: int:
	get: return _prop_getter("progress", "coins")
	set(new): _prop_setter("progress", "coins", new, func(x): return x >= 0)

var total_exp: int:
	get: return _prop_getter("progress", "total_exp")
	set(new): _prop_setter("progress", "total_exp", new, func(x): return x >= 0)

var current_theme: String:
	get: return _prop_getter("progress", "current_theme")
	set(new): _prop_setter("progress", "current_theme", new)

var current_skin: String:
	get: return _prop_getter("progress", "current_skin")
	set(new): _prop_setter("progress", "current_skin", new)

func _ready() -> void:
	_load_current_save()
	_sync_with_remote()

func _load_current_save() -> void:
	current_save = ConfigFile.new()

	if FileAccess.file_exists(SAVE_PATHS[SaveTypes.AUTH]):
		current_save_type = SaveTypes.AUTH
	elif FileAccess.file_exists(SAVE_PATHS[SaveTypes.GUEST]):
		current_save_type = SaveTypes.GUEST
	else:
		current_save_type = SaveTypes.GUEST
		_initialize_guest_save()
	
	current_save.load(SAVE_PATHS[current_save_type])

func _initialize_guest_save() -> void:
	current_save.load(_DEFAULT_GUEST_SAVE)
	_username = generate_guest_username()

func _initialize_talo_save() -> void:
	current_save.load(_DEFAULT_AUTH_SAVE)
	_username = Talo.current_player.identifier

func _sync_with_remote() -> void:
	var player: TaloPlayer

	if Talo.identity_check(false) != OK:
		var service := "talo" if current_save_type == SaveTypes.AUTH else "username"
		player = await Talo.players.identify(service, username)
		if player == null:
			return

	push_high_score("global", highscore)
	_sync_decision_tree()

func _sync_decision_tree() -> void:
	# TODO: implement
	return

func generate_guest_username() -> String:
	var device_id = OS.get_unique_id()
	var hash_suffix = String.num_int64(device_id.hash(), 16).pad_zeros(6).substr(0, 6)
	return "Guest_" + hash_suffix

func push_high_score(leaderboard_internal_name: String, score: int) -> void:
	var res := await Talo.leaderboards.add_entry(leaderboard_internal_name, score)
	assert(is_instance_valid(res))

func _prop_setter(section: String, key: String, new_value, condition: Callable = Callable()) -> void:
	if condition.is_valid() and not condition.call(new_value):
		return
	current_save.set_value(section, key, new_value)
	current_save.save(SAVE_PATHS[current_save_type])
	_sync_with_remote()

func _prop_getter(section: String, key: String, default: Variant = null) -> Variant:
	return current_save.get_value(section, key, default)

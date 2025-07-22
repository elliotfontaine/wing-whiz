extends Control

signal closed

const entry_scene: PackedScene = preload("res://scenes/ui/leaderboard_entry.tscn")

@export var leaderboard_internal_name: String
@export var include_archived: bool

@onready var margin_container: MarginContainer = %MarginContainer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var close_button: TextureButton = %CloseButton
@onready var entries_container: VBoxContainer = %EntriesContainer
@onready var current_player_entry: HBoxContainer = %CurrentPlayerEntry

var _entries_error: bool

func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	ResponsiveUI.ratio_changed.connect(_on_ratio_changed)
	_on_ratio_changed(ResponsiveUI.ratio)
	_load_current_player_entry()
	animation_player.play("appear")
	_build_entry_list() # will show cache if already present

	await _cache_entries()
	_build_entry_list()

func _add_negative_space() -> void:
	var h_sep = HSeparator.new()
	h_sep.add_theme_constant_override(&"separation", 0)
	h_sep.add_theme_stylebox_override(&"separator", StyleBoxEmpty.new())
	entries_container.add_child(h_sep)

func _build_entry_list() -> void:
	var talo_entries: Array[TaloLeaderboardEntry] = Talo.leaderboards.get_cached_entries(leaderboard_internal_name)
	if talo_entries.is_empty() or talo_entries.size() == 1:
		print("cache is empty")
		return
	
	for child in entries_container.get_children():
		child.queue_free()
	
	_add_negative_space()
	for talo_entry in talo_entries:
		if Talo.identity_check(false) == OK and talo_entry.player_alias.identifier == Talo.current_alias.identifier:
			current_player_entry.set_data_from_talo(talo_entry)
		var entry_instance = entry_scene.instantiate()
		entries_container.add_child(entry_instance)
		entry_instance.set_data_from_talo(talo_entry)
	_add_negative_space()

func _cache_entries() -> void:
	var page := 0
	var done := false

	while !done:
		var options := Talo.leaderboards.GetEntriesOptions.new()
		options.page = page
		options.include_archived = include_archived

		var res := await Talo.leaderboards.get_entries(leaderboard_internal_name, options)
		if not is_instance_valid(res):
			_entries_error = true
			return
		
		var is_last_page := res.is_last_page

		if is_last_page or page == 2: # we only want the top 100 entries
			done = true
		else:
			page += 1
	
	if Talo.identity_check(false) == OK:
		var options := Talo.leaderboards.GetEntriesOptions.new()
		options.page = 0
		options.include_archived = include_archived
		var res := await Talo.leaderboards.get_entries_for_current_player(leaderboard_internal_name, options)
		if not is_instance_valid(res):
			_entries_error = true

func _load_current_player_entry() -> void:
	current_player_entry.set_rank("?")
	current_player_entry.set_username(GameSaveManager.username)
	current_player_entry.set_score(GameSaveManager.highscore)

func _on_close_pressed() -> void:
	animation_player.play_backwards("appear")
	await animation_player.animation_finished
	closed.emit()
	queue_free()

func _on_ratio_changed(ratio: float) -> void:
	if ratio < 0.8:
		margin_container.scale = Vector2(6, 6)
		margin_container.add_theme_constant_override("margin_left", 8)
		margin_container.add_theme_constant_override("margin_right", 8)
	else:
		margin_container.scale = Vector2(5, 5)
		margin_container.add_theme_constant_override("margin_left", 0)
		margin_container.add_theme_constant_override("margin_right", 0)

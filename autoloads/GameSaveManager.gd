extends Node

const save_path: String = "user://save.dat"

var save: ConfigFile = ConfigFile.new()

# Score
var highscore: int:
	set(new):
		if new <= highscore:
			return
		save.set_value("progress", "highscore", new)
		save.save(save_path)
		var _res: LeaderboardsAPI.AddEntryResult = await Talo.leaderboards.add_entry("global", new)
	get:
		return save.get_value("progress", "highscore", 0)

func _ready() -> void:
	if !FileAccess.file_exists(save_path):
		print("No save file. Creating new one.")
		_create_default_save()
	else:
		print("Existing save file at: ", save_path)
	_load_save()

func _load_save() -> void:
	save.load(save_path)

func _create_default_save() -> void:
	save.set_value("progress", "highscore", 0)
	save.save(save_path)

extends Node

var save_path: String = "user://save.dat"
var save = ConfigFile.new()

# Score
var best_score: int:
	set(new_record):
		save.set_value("score", "best_score", new_record)
		save.save(save_path)
	get:
		return save.get_value("score", "best_score", 0)

# Settings
var volume_global: float:
	set(new_volume):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Global"), linear_to_db(new_volume))
		save.set_value("settings", "volume_global", new_volume)
		save.save(save_path)
	get:
		return save.get_value("settings", "volume_global", 1.0)
var volume_music: float:
	set(new_volume):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(new_volume))
		save.set_value("settings", "volume_music", new_volume)
		save.save(save_path)
	get:
		return save.get_value("settings", "volume_music", 1.0)
var volume_sfx: float:
	set(new_volume):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(new_volume))
		save.set_value("settings", "volume_sfx", new_volume)
		save.save(save_path)
	get:
		return save.get_value("settings", "volume_sfx", 1.0)

func _ready() -> void:
	if !FileAccess.file_exists(save_path):
		print("No save file. Creating new one.")
		_create_default_save()
	else:
		print("Existing save file at: ", save_path)
	_load_save()

func _load_save() -> void:
	save.load(save_path)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Global"), linear_to_db(volume_global))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(volume_music))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(volume_sfx))

func _create_default_save() -> void:
	save.set_value("score", "best_score", 0)
	save.set_value("settings", "volume_global", 1.0)
	save.set_value("settings", "volume_music", 1.0)
	save.set_value("settings", "volume_sfx", 1.0)
	save.save(save_path)

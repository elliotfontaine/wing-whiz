extends Node

const save_path: String = "user://game_settings.cfg"

var save: ConfigFile = ConfigFile.new()

var volume_global: float:
	set(new_volume):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Global"), linear_to_db(new_volume))
		save.set_value("volume", "global", new_volume)
		save.save(save_path)
	get:
		return save.get_value("volume", "global", 1.0)

var volume_music: float:
	set(new_volume):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(new_volume))
		save.set_value("volume", "music", new_volume)
		save.save(save_path)
	get:
		return save.get_value("volume", "music", 1.0)

var volume_sfx: float:
	set(new_volume):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(new_volume))
		save.set_value("volume", "sfx", new_volume)
		save.save(save_path)
	get:
		return save.get_value("volume", "sfx", 1.0)

func _ready() -> void:
	if !FileAccess.file_exists(save_path):
		print("No settings file. Creating new one.")
		_create_default_save()
	else:
		print("Existing settings file at: ", save_path)
	_load_save()

func _load_save() -> void:
	save.load(save_path)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Global"), linear_to_db(volume_global))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(volume_music))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(volume_sfx))

func _create_default_save() -> void:
	save.set_value("volume", "global", 1.0)
	save.set_value("volume", "music", 1.0)
	save.set_value("volume", "sfx", 1.0)
	save.save(save_path)

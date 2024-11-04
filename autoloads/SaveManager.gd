extends Node

var save_path: String = "user://save.dat"
var save = ConfigFile.new()

# Use setters and getters to access/change any save file item.
var best_score: int:
	set(new_record):
		save.set_value("score", "best_score", new_record)
		save.save(save_path)
	get: 
		return save.get_value("score", "best_score")
# Another exemple:
#var player_skin: int:
	#set(new_skin):
		#save.set_value("misc", "player_skin", new_skin)
		#save.save(save_path)
	#get: 
		#return save.get_value("misc", "player_skin")

func _ready() -> void:
	if !FileAccess.file_exists(save_path):
		print("No save file. Creating new one.")
		_create_default_save()
	else:
		print("Existing save file at: ", save_path)
	save.load(save_path)

func _create_default_save() -> void:
	save.set_value("score", "best_score", 0)
	save.save(save_path)

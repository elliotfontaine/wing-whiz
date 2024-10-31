extends Sprite2D

@onready var day := preload("res://assets/background_day.png")
@onready var night := preload("res://assets/background_night.png")

func _ready() -> void:
	var datetime := Time.get_datetime_dict_from_system()
	print_debug(str(datetime))
	if 5 < datetime.hour and datetime.hour < 21:
		texture = day
	else:
		texture = night
	

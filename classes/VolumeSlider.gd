@tool
extends HSlider
class_name VolumeSlider

enum AudioBus {Master = 0}
@export var audio_bus: AudioBus = 0 as AudioBus
@onready var bus_name: String = AudioServer.get_bus_name(audio_bus)

func _ready() -> void:
    value_changed.connect(_on_value_changed)
    value = SaveManager.get("volume_" + bus_name.to_lower())

func _on_value_changed(new_value: float) -> void:
    SaveManager.set("volume_" + bus_name.to_lower(), new_value)

func _validate_property(property: Dictionary):
    if property.name == "audio_bus":
        var busNumber = AudioServer.bus_count
        var options = ""
        for i in busNumber:
            if i > 0:
                options += ","
            var busName = AudioServer.get_bus_name(i)
            options += busName
        property.hint_string = options

## The following is portable (doesn't depend on the SaveManager autoload)

# @tool
# extends HSlider
#
# enum AudioBus {Master = 0}
# @export var audio_bus: AudioBus = 0 as AudioBus
# @onready var bus_name: String = AudioServer.get_bus_name(audio_bus)
#
# func _ready() -> void:
#     value_changed.connect(_on_value_changed)
#     value = db_to_linear(AudioServer.get_bus_volume_db(audio_bus))
#
# func _on_value_changed(new_value: float) -> void:
#     AudioServer.set_bus_volume_db(audio_bus, linear_to_db(new_value))
#
# func _validate_property(property: Dictionary):
#     if property.name == "audio_bus":
#         var busNumber = AudioServer.bus_count
#         var options = ""
#         for i in busNumber:
#             if i > 0:
#                 options += ","
#             var busName = AudioServer.get_bus_name(i)
#             options += busName
#         property.hint_string = options
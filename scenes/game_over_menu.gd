extends Control

const BEST_SCORE_TEMPLATE := "[right]%s[/right]"
#const NEW_BEST_SCORE_TEMPLATE := "[right][rainbow sat=0.6 val=0.9][wave amp=15.0 freq=7.0]New [/wave][/rainbow]%s[/right]"
const NEW_BEST_SCORE_SHORT_TEMPLATE := "[right][rainbow sat=0.6 val=0.9][wave amp=15.0 freq=5.0]%s[/wave][/rainbow][/right]"

const THRESHOLDS := {
	"bronze": 10,
	"silver": 30,
	"gold": 100,
	"platinum": 300
}

@export var retry_scene: SceneChanger.MainScenes
@export var home_scene: SceneChanger.MainScenes

const TWITTER_SHARE_URL := "https://twitter.com/intent/tweet?text="
var TWITTER_SHARE_TEMPLATE := "✨ I achieved a score of %s in Wing Whiz ! ✨\n
Download or Play the game at{itch}".format({"itch": Globals.ITCHIO_URL})

#TODO: replace with other medals when assets are made
var medal_textures := {
	"bronze": preload("res://assets/ui/medals/medal_V4_bronze.png"),
	"silver": preload("res://assets/ui/medals/medal_V4_silver.png"),
	"gold": preload("res://assets/ui/medals/medal_V4_gold.png"),
	"platinum": preload("res://assets/ui/medals/medal_V4_platinum.png")
}

var game_over_textures = {
	"long": preload("res://assets/ui/titles/game_over.png"),
	"short": preload("res://assets/ui/titles/game_over_shorter.png")
}

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var medal: TextureRect = %Medal
@onready var score_label: Label = %Score
@onready var best_label := %Best
@onready var retry_button: Button = %RetryButton
@onready var home_button: Button = %HomeButton
@onready var share_button: Button = %ShareButton
@onready var title: TextureRect = %Title
@onready var score_up_sound: AudioStreamPlayer = %ScoreUpSound

func _ready() -> void:
	score_label.text = str(0)
	medal.texture = null
	retry_button.pressed.connect(SceneChanger.change_to.bind(retry_scene))
	home_button.pressed.connect(SceneChanger.change_to.bind(home_scene))
	ResponsiveUI.ratio_changed.connect(_on_ratio_changed)
	_on_ratio_changed(ResponsiveUI.ratio)

func appear(new_score: int, previous_best_score: int) -> void:
	best_label.text = BEST_SCORE_TEMPLATE % previous_best_score
	share_button.pressed.connect(_on_share_pressed.bind(new_score))
	animation_player.play("appear")
	var score_tween := score_label.create_tween().set_trans(Tween.TRANS_QUAD)
	score_tween.tween_method(_update_score, 0, new_score, 1.5)
	await animation_player.animation_finished
	animation_player.play("idle")
	
	await score_tween.finished
	if new_score > previous_best_score:
		var record_tween := best_label.create_tween().set_trans(Tween.TRANS_QUAD)
		best_label.text = NEW_BEST_SCORE_SHORT_TEMPLATE % new_score
		best_label.pivot_offset = best_label.size / 2
		best_label.scale *= 5
		record_tween.tween_property(best_label, "scale", best_label.scale / 5, 0.4)
	update_medal(new_score)

func _update_score(new_score: int):
	if new_score != score_label.text.to_int():
		score_label.text = str(new_score)
		score_up_sound.pitch_scale += 0.005
		score_up_sound.play()


func update_medal(score: int) -> void:
	var new_medal = null
	for medal_name in THRESHOLDS.keys():
		if score >= THRESHOLDS[medal_name]:
			new_medal = medal_name
		else: break
	if new_medal:
		medal.texture = medal_textures[new_medal]
	else:
		medal.texture = null

func _on_share_pressed(score: int) -> void:
	var url = TWITTER_SHARE_URL + (TWITTER_SHARE_TEMPLATE % score).uri_encode()
	OS.shell_open(url)

func _on_ratio_changed(ratio) -> void:
	if ratio < 0.8:
		$GameOverPanel/MarginContainer.scale = Vector2(7.5, 7.5)
		$GameOverPanel/MarginContainer.add_theme_constant_override("margin_left", 35)
		$GameOverPanel/MarginContainer.add_theme_constant_override("margin_right", 35)
		$GameOverPanel/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Menu2.columns = 1
		$GameOverPanel/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Menu2/VSeparator.visible = false
		title.texture = game_over_textures["short"]
		title.scale = Vector2(7.5, 7.5)
		title.offset_bottom = -575
	else:
		$GameOverPanel/MarginContainer.scale = Vector2(5, 5)
		$GameOverPanel/MarginContainer.add_theme_constant_override("margin_left", 8)
		$GameOverPanel/MarginContainer.add_theme_constant_override("margin_right", 8)
		$GameOverPanel/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Menu2.columns = 3
		$GameOverPanel/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Menu2/VSeparator.visible = true
		title.texture = game_over_textures["long"]
		title.scale = Vector2(5.0, 5.0)
		title.offset_bottom = -269

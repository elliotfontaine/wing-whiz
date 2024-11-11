extends Control

const TWITTER_SHARE_URL = "https://twitter.com/intent/tweet?text="
var TWITTER_SHARE_TEMPLATE = "✨ I achieved a score of %s in Wing Whiz ! ✨\n
Download or Play the game at{itch}".format({"itch": Globals.ITCHIO_URL})

var BEST_SCORE_TEMPLATE = "[right]%s[/right]"
var NEW_BEST_SCORE_TEMPLATE = "[right][rainbow sat=0.6 val=0.9][wave amp=15.0 freq=7.0]New [/wave][/rainbow]%s[/right]"

#TODO: replace with other medals when assets are made
var medal_textures := {
	"bronze": preload("res://assets/ui/medals/bronze_2.png"),
	"silver": preload("res://assets/ui/medals/bronze_2.png"),
	"gold": preload("res://assets/ui/medals/bronze_2.png"),
	"platinum": preload("res://assets/ui/medals/bronze_2.png")
}

var thresholds := {
	"bronze": 5,
	"silver": 30,
	"gold": 100,
	"platinum": 500
}

var retry_scene: String = "res://scenes/main.tscn"
var menu_scene: String = "res://scenes/home.tscn"

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var medal: TextureRect = %Medal
@onready var score_label: Label = %Score
@onready var best_label := %Best
@onready var retry_button: Button = %RetryButton
@onready var home_button: Button = %HomeButton
@onready var share_button: Button = %ShareButton

func _ready() -> void:
	score_label.text = str(0)
	medal.texture = null
	retry_button.pressed.connect(SceneChanger.change_to.bind(retry_scene))
	home_button.pressed.connect(SceneChanger.change_to.bind(menu_scene))

func appear(new_score: int, previous_best_score: int) -> void:
	best_label.text = BEST_SCORE_TEMPLATE % previous_best_score
	share_button.pressed.connect(_on_share_pressed.bind(new_score))
	animation_player.play("appear")
	var score_tween := score_label.create_tween().set_trans(Tween.TRANS_QUAD)
	score_tween.tween_method(_update_score, 0, new_score, 1.5)
	await animation_player.animation_finished
	animation_player.play("idle")
	
	await score_tween.finished
	update_medal(new_score)
	if new_score > previous_best_score:
		var record_tween := best_label.create_tween().set_trans(Tween.TRANS_QUAD)
		best_label.text = NEW_BEST_SCORE_TEMPLATE % new_score
		best_label.pivot_offset = best_label.size / 2
		best_label.scale *= 5
		record_tween.tween_property(best_label, "scale", best_label.scale / 5, 1)

func _update_score(new_score: int):
	score_label.text = str(new_score)

func update_medal(score: int) -> void:
	var new_medal = null
	for medal_name in thresholds.keys():
		if score >= thresholds[medal_name]:
			new_medal = medal_name
		else: break
	if new_medal:
		medal.texture = medal_textures[new_medal]
	else:
		medal.texture = null

func _on_share_pressed(score: int) -> void:
	var url = TWITTER_SHARE_URL + (TWITTER_SHARE_TEMPLATE % score).uri_encode()
	OS.shell_open(url)

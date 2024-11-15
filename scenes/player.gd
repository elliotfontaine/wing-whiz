extends CharacterBody2D

signal state_changed(new_state)

@export var gravity: float = 90
@export var flap_strength: float = 1350.0
@export var terminal_y_velocity: float = 30.0

const FLAP_ANGLE := -PI / 6
var MAX_ANGLE := PI / 2.2

# Player is a finite-state-machine
enum States {READY, FLYING, DEAD, AUTO}
var state: States: set = _set_state
var ready_tween := create_tween().set_trans(Tween.TRANS_QUAD).set_loops()


@onready var animated_sprite := %AnimatedSprite2D
@onready var hit_sound := %HitSound
@onready var flap_sound: AudioStreamPlayer = %FlapSound
@onready var die_sound: AudioStreamPlayer = %DieSound

func _ready():
	state = States.READY

func _physics_process(delta: float):
	var flap_input := Input.is_action_just_pressed("flap")
	match state:
		States.READY:
			if flap_input:
				state = States.FLYING
				flap(flap_strength, delta)
		States.FLYING:
			if flap_input:
				flap(flap_strength, delta)
			apply_gravity(gravity, delta)
			var collision = move_and_collide(velocity)
			if collision:
				state = States.DEAD
				flap(flap_strength / 2, delta)
				print_debug("I, ", name, ", collided with ", collision.get_collider().name, "!")
		States.DEAD:
			apply_gravity(gravity, delta)
			var collision = move_and_collide(velocity)
			if die_sound.playing and collision:
				var fade_out = create_tween()
				fade_out.tween_property(die_sound, "volume_db", linear_to_db(0.0001), 0.1)
		States.AUTO:
			apply_gravity(gravity, delta)
			move_and_collide(velocity)
			if position.y > 600:
				flap(flap_strength / 1.5, delta)
			if position.y > 400 and randf() > 0.96:
				flap(flap_strength / 1.5, delta)

func flap(strength: float, delta: float) -> void:
	velocity.y = -strength * delta
	animated_sprite.rotation = FLAP_ANGLE
	if state != States.AUTO:
		flap_sound.play()

func apply_gravity(g: float, delta: float) -> void:
	velocity.y += g * delta
	velocity.y = min(velocity.y, terminal_y_velocity)
	if velocity.y > 0:
		animated_sprite.rotate(velocity.y * delta * 0.5)
		animated_sprite.rotation = min(MAX_ANGLE, animated_sprite.rotation)

func _set_state(new_state: States) -> void:
	print_debug(str(new_state))
	state = new_state
	state_changed.emit(new_state)
	match new_state:
		States.READY:
			animated_sprite.play()
			ready_tween.tween_property(self, "position:y", position.y - 20, 0.5)
			ready_tween.tween_property(self, "position:y", position.y, 0.5)
			collision_mask = 0
		States.FLYING:
			animated_sprite.play()
			ready_tween.stop()
			collision_mask = 6
		States.DEAD:
			animated_sprite.stop()
			collision_mask = 4
			hit_sound.play()
			await get_tree().create_timer(0.05).timeout
			var fade_in = create_tween()
			var target_volume = die_sound.volume_db
			die_sound.volume_db = linear_to_db(0.0001)
			fade_in.tween_property(die_sound, "volume_db", target_volume, 0.4)
			die_sound.play()
		States.AUTO:
			animated_sprite.play()
			ready_tween.stop()
			collision_mask = 0

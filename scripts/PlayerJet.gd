# scripts/PlayerJet.gd
extends CharacterBody3D

signal jet_damaged(amount: float)
signal coolant_collected(amount: float)
signal shield_collected(amount: float)

const BOUNDS_X := 6.5
const BOUNDS_Y := 3.8
const MOVE_SPEED := 11.0
const SMOOTH_LAMBDA := 18.0

var target_pos := Vector2.ZERO
var is_invulnerable := false
var is_barrel_rolling := false
var roll_timer := 0.0
var roll_duration := 0.45
var roll_direction := 1.0

var speed_multiplier := 1.0
var last_tap_left_time := -10.0
var last_tap_right_time := -10.0
const DOUBLE_TAP_WINDOW := 0.28

@onready var model_node: Node3D = $ModelRoot
@onready var collision_area: Area3D = $HitArea

func _ready() -> void:
	target_pos = Vector2(position.x, position.y)
	if collision_area:
		collision_area.area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	# Calculate effective delta so steering remains 100% responsive during Focus Time-Slow
	var time_factor := Engine.time_scale if Engine.time_scale > 0.05 else 1.0
	var jet_delta := delta / time_factor

	# Boost and Airbrake handling
	if Input.is_action_pressed("boost"):
		speed_multiplier = 1.6
	elif Input.is_action_pressed("airbrake"):
		speed_multiplier = 0.55
	else:
		speed_multiplier = 1.0

	# Input movement
	var input_vec := Input.get_vector("move_left", "move_right", "move_down", "move_up")
	target_pos.x = clampf(target_pos.x + input_vec.x * MOVE_SPEED * speed_multiplier * jet_delta, -BOUNDS_X, BOUNDS_X)
	target_pos.y = clampf(target_pos.y + input_vec.y * MOVE_SPEED * speed_multiplier * jet_delta, -BOUNDS_Y, BOUNDS_Y)

	# Framerate-independent smoothing
	var alpha := 1.0 - exp(-SMOOTH_LAMBDA * jet_delta)
	position.x = lerpf(position.x, target_pos.x, alpha)
	position.y = lerpf(position.y, target_pos.y, alpha)

	# Check for double-tap A/D barrel roll
	var now := Time.get_ticks_msec() / 1000.0
	if Input.is_action_just_pressed("move_left"):
		if (now - last_tap_left_time) <= DOUBLE_TAP_WINDOW:
			trigger_barrel_roll(-1.0)
		last_tap_left_time = now
	elif Input.is_action_just_pressed("move_right"):
		if (now - last_tap_right_time) <= DOUBLE_TAP_WINDOW:
			trigger_barrel_roll(1.0)
		last_tap_right_time = now

	# Barrel roll execution
	if is_barrel_rolling:
		roll_timer += jet_delta
		var roll_progress := roll_timer / roll_duration
		if model_node:
			model_node.rotation.z = roll_direction * roll_progress * TAU
		if roll_timer >= roll_duration:
			is_barrel_rolling = false
			is_invulnerable = false
			if model_node:
				model_node.rotation.z = 0.0
	else:
		# Check for dedicated barrel roll action trigger
		if Input.is_action_just_pressed("barrel_roll"):
			trigger_barrel_roll(1.0 if input_vec.x >= 0.0 else -1.0)
		else:
			# Dynamic banking and pitch
			var vel_x := target_pos.x - position.x
			var vel_y := target_pos.y - position.y
			rotation.z = lerpf(rotation.z, clampf(-vel_x * 0.35, -0.65, 0.65), alpha)
			rotation.x = lerpf(rotation.x, clampf(vel_y * 0.25, -0.45, 0.45), alpha)

func trigger_barrel_roll(dir: float = 1.0) -> void:
	if is_barrel_rolling:
		return
	is_barrel_rolling = true
	is_invulnerable = true
	roll_timer = 0.0
	roll_direction = dir
	if has_node("/root/SoundEffects"):
		get_node("/root/SoundEffects").play_barrel_roll()

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("hazards"):
		if not is_invulnerable:
			if has_node("/root/SoundEffects"):
				get_node("/root/SoundEffects").play_shield_hit()
			if has_node("/root/GameManager"):
				get_node("/root/GameManager").apply_shield_damage(25.0)
			jet_damaged.emit(25.0)
		else:
			# Deflected hazard during barrel roll!
			if has_node("/root/SoundEffects"):
				get_node("/root/SoundEffects").play_barrel_roll()
	elif area.is_in_group("pickup_coolant"):
		if has_node("/root/SoundEffects"):
			get_node("/root/SoundEffects").play_pickup()
		if has_node("/root/GameManager"):
			get_node("/root/GameManager").apply_coolant(35.0)
		coolant_collected.emit(35.0)
		area.get_parent().queue_free()
	elif area.is_in_group("pickup_shield"):
		if has_node("/root/SoundEffects"):
			get_node("/root/SoundEffects").play_pickup()
		if has_node("/root/GameManager"):
			get_node("/root/GameManager").restore_shield(25.0)
		shield_collected.emit(25.0)
		area.get_parent().queue_free()

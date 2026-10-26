# scripts/HUD.gd
extends CanvasLayer

@onready var reticle_box: Control = $ReticleBox
@onready var tactical_banner: Control = $TacticalBanner
@onready var clue_label: Label = $TacticalBanner/VBox/ClueLabel
@onready var buttons_container: HBoxContainer = $TacticalBanner/VBox/ButtonsContainer
@onready var bro_avatar: Control = $CommsWidget/BroAvatar
@onready var bro_dialogue_label: Label = $CommsWidget/DialogueBox/Label
@onready var score_label: Label = $TopLeft/ScoreLabel
@onready var combo_badge: Label = $TopLeft/ComboBadge
@onready var mastery_label: Label = $TopLeft/MasteryLabel
@onready var shield_bar: ProgressBar = $BottomLeft/ShieldBar
@onready var focus_bar: ProgressBar = $BottomLeft/FocusBar
@onready var overheat_bar: ProgressBar = $BottomLeft/OverheatBar
@onready var lockout_label: Label = $BottomLeft/LockoutLabel
@onready var boss_container: Control = $BossHealthContainer
@onready var boss_name_label: Label = $BossHealthContainer/BossNameLabel
@onready var boss_bar: ProgressBar = $BossHealthContainer/BossBar
@onready var crt_overlay: ColorRect = $CRTOverlay

var dialogue_timer: float = 0.0

func _ready() -> void:
	if reticle_box:
		reticle_box.visible = false
	if tactical_banner:
		tactical_banner.visible = false
	if lockout_label:
		lockout_label.visible = false
	if boss_container:
		boss_container.visible = false

	# Connect to GameManager signals
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.score_changed.connect(_on_score_changed)
		gm.shield_changed.connect(_on_shield_changed)
		gm.overheat_changed.connect(_on_overheat_changed)
		gm.bro_callout.connect(_on_bro_callout)

		_on_score_changed(gm.score, gm.combo_multiplier)
		_on_shield_changed(gm.shield_hp, gm.max_shield_hp)
		_on_overheat_changed(gm.cognitive_overheat, gm.is_overheated_lockout)

		if crt_overlay:
			var crt_on: bool = gm.save_data.get("settings", {}).get("crt_scanlines", true)
			crt_overlay.visible = crt_on

	# Initial B.R.O. greeting
	call_deferred("trigger_bro_message", "IDLE", "LOCK ONTO THOSE SCIENTIFIC ROOTS, BRO!")

func _process(delta: float) -> void:
	if dialogue_timer > 0.0:
		dialogue_timer -= delta
		if dialogue_timer <= 0.0:
			if bro_avatar and bro_avatar.has_method("set_talking"):
				bro_avatar.set_talking(false)

func update_reticle_projection(camera: Camera3D, locked_target: Node3D) -> void:
	if locked_target == null or not is_instance_valid(locked_target) or camera == null:
		if reticle_box:
			reticle_box.visible = false
		return
	if camera.is_position_behind(locked_target.global_position):
		if reticle_box:
			reticle_box.visible = false
		return

	if reticle_box:
		reticle_box.visible = true
		var screen_pos := camera.unproject_position(locked_target.global_position)
		reticle_box.position = screen_pos - (reticle_box.size * 0.5)

func display_prompt(prompt: Dictionary) -> void:
	if tactical_banner == null or prompt.is_empty():
		return
	tactical_banner.visible = true

	if clue_label:
		var target_meaning: String = prompt.get("clue", "")
		clue_label.text = "TARGET CLUE: \"" + target_meaning.to_upper() + "\""

	var options: Array = prompt.get("options", [])
	var keys := ["1 / Q", "2 / E", "3 / R", "4 / F"]
	var colors := [Color("#00F0FF"), Color("#39FF14"), Color("#FFE600"), Color("#FF007F")]

	var btns := buttons_container.get_children()
	for i in range(btns.size()):
		var btn := btns[i] as Button
		if i < options.size():
			var opt: Dictionary = options[i]
			var root_text: String = opt.get("root", opt.get("id", ""))
			btn.text = "[" + keys[i] + "] " + root_text
			btn.modulate = colors[i]
			btn.visible = true
		else:
			btn.visible = false

func clear_prompt() -> void:
	if tactical_banner:
		tactical_banner.visible = false
	if reticle_box:
		reticle_box.visible = false

func _on_score_changed(new_score: int, combo: int) -> void:
	if score_label:
		score_label.text = "SCORE: %07d" % new_score
	if combo_badge:
		combo_badge.text = "%dX BRO-FACTOR" % combo
		var colors = {1: Color.WHITE, 2: Color("#00F0FF"), 4: Color("#FFE600"), 8: Color("#FF007F")}
		combo_badge.modulate = colors.get(combo, Color.WHITE)

func _on_shield_changed(hp: float, max_hp: float) -> void:
	if shield_bar:
		shield_bar.max_value = max_hp
		shield_bar.value = hp

func _on_overheat_changed(heat: float, is_locked: bool) -> void:
	if overheat_bar:
		overheat_bar.value = heat
	if lockout_label:
		lockout_label.visible = is_locked

func _on_bro_callout(state: String, message: String) -> void:
	trigger_bro_message(state, message)

func trigger_bro_message(state: String, message: String) -> void:
	if bro_dialogue_label:
		bro_dialogue_label.text = message
	if bro_avatar and bro_avatar.has_method("set_state"):
		bro_avatar.set_state(state)
		bro_avatar.set_talking(true)
	dialogue_timer = 2.8

	if has_node("/root/SoundEffects"):
		var syllables := clampi(int(message.length() / 8), 3, 6)
		get_node("/root/SoundEffects").play_bro_voice_cadence(syllables)

func update_focus(current: float, max_val: float) -> void:
	if focus_bar:
		focus_bar.max_value = max_val
		focus_bar.value = current

func update_mastery(cleared: int, total: int) -> void:
	if mastery_label:
		mastery_label.text = "ROOTS MASTERED: %d / %d" % [cleared, total]

func show_boss_health(bname: String, current_hp: float, max_hp: float) -> void:
	clear_prompt()
	if boss_container:
		boss_container.visible = true
	if boss_name_label:
		boss_name_label.text = bname.to_upper()
	update_boss_hp(current_hp, max_hp)

func update_boss_hp(current_hp: float, max_hp: float) -> void:
	if boss_bar:
		boss_bar.max_value = max_hp
		boss_bar.value = current_hp

func hide_boss_health() -> void:
	if boss_container:
		boss_container.visible = false

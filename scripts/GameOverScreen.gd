# scripts/GameOverScreen.gd
extends CanvasLayer

@onready var dimmer: ColorRect = $Dimmer
@onready var panel: PanelContainer = $Panel
@onready var header_label: Label = $Panel/VBox/HeaderLabel
@onready var subheader_label: Label = $Panel/VBox/SubHeaderLabel
@onready var grade_label: Label = $Panel/VBox/GradeBox/GradeLabel
@onready var score_label: Label = $Panel/VBox/StatsBox/ScoreLabel
@onready var record_label: Label = $Panel/VBox/StatsBox/RecordLabel
@onready var missed_label: Label = $Panel/VBox/StatsBox/MissedLabel
@onready var accuracy_label: Label = $Panel/VBox/StatsBox/AccuracyLabel
@onready var combo_label: Label = $Panel/VBox/StatsBox/ComboLabel
@onready var retry_btn: Button = $Panel/VBox/Buttons/RetryBtn
@onready var menu_btn: Button = $Panel/VBox/Buttons/MenuBtn

func _get_tree_safe() -> SceneTree:
	if is_inside_tree() and get_tree():
		return get_tree()
	var main_loop := Engine.get_main_loop()
	if main_loop is SceneTree:
		return main_loop as SceneTree
	if Engine.has_meta("active_tree"):
		return Engine.get_meta("active_tree") as SceneTree
	return null

func _get_synthwave_ui() -> Node:
	if is_inside_tree() and has_node("/root/SynthwaveUI"):
		return get_node("/root/SynthwaveUI")
	var t := _get_tree_safe()
	if t and t.root and t.root.has_node("SynthwaveUI"):
		return t.root.get_node("SynthwaveUI")
	return null

func _get_sound_effects() -> Node:
	if is_inside_tree() and has_node("/root/SoundEffects"):
		return get_node("/root/SoundEffects")
	var t := _get_tree_safe()
	if t and t.root and t.root.has_node("SoundEffects"):
		return t.root.get_node("SoundEffects")
	return null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	var sui = _get_synthwave_ui()
	if retry_btn:
		retry_btn.pressed.connect(_on_retry_pressed)
		retry_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		if sui:
			if sui.has_method("apply_button_style"):
				sui.apply_button_style(retry_btn)
			elif sui.has_method("apply_btn_style"):
				sui.apply_btn_style(retry_btn)

	if menu_btn:
		menu_btn.pressed.connect(_on_menu_pressed)
		menu_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		if sui:
			if sui.has_method("apply_button_style"):
				sui.apply_button_style(menu_btn)
			elif sui.has_method("apply_btn_style"):
				sui.apply_btn_style(menu_btn)

func setup_results(summary: Dictionary) -> void:
	var survived: bool = summary.get("survived", false)
	var score: int = int(summary.get("score", 0))
	var grade: String = summary.get("grade", "D")
	var words_missed: int = int(summary.get("words_missed", 0))
	var accuracy: float = float(summary.get("accuracy", 0.0))
	var is_record: bool = summary.get("is_new_high_score", false)
	var max_combo: int = int(summary.get("max_combo", 1))
	var sector_num: int = int(summary.get("sector", 1))

	var style: StyleBoxFlat = null
	if panel:
		style = panel.get_theme_stylebox("panel") as StyleBoxFlat
	if style:
		style = style.duplicate()
		panel.add_theme_stylebox_override("panel", style)

	if survived:
		if header_label:
			header_label.text = "SECTOR 0%d CLEARED" % sector_num
			header_label.modulate = Color.WHITE
			header_label.add_theme_color_override("font_color", Color("#39FF14"))
			header_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.45, 0.1, 0.75))
			header_label.add_theme_constant_override("shadow_offset_x", 0)
			header_label.add_theme_constant_override("shadow_offset_y", 2)
			header_label.add_theme_constant_override("shadow_outline_size", 4)
		if subheader_label:
			subheader_label.text = "ANOMALY CORE ANNIHILATED — MISSION ACCOMPLISHED!"
			subheader_label.modulate = Color.WHITE
			subheader_label.add_theme_color_override("font_color", Color("#00FFFF"))
		if dimmer:
			dimmer.color = Color(0.02, 0.04, 0.08, 0.8)
		if style:
			style.border_color = Color("#39FF14")
	else:
		if header_label:
			header_label.text = "CRITICAL FAILURE"
			header_label.modulate = Color.WHITE
			header_label.add_theme_color_override("font_color", Color("#FF0055"))
			header_label.add_theme_color_override("font_shadow_color", Color(0.45, 0.0, 0.1, 0.75))
			header_label.add_theme_constant_override("shadow_offset_x", 0)
			header_label.add_theme_constant_override("shadow_offset_y", 2)
			header_label.add_theme_constant_override("shadow_outline_size", 4)
		if subheader_label:
			subheader_label.text = "SHIELD INTEGRITY DEPLETED — SHIP DESTROYED"
			subheader_label.modulate = Color.WHITE
			subheader_label.add_theme_color_override("font_color", Color("#FFAA00"))
		if dimmer:
			dimmer.color = Color(0.12, 0.01, 0.03, 0.85)
		if style:
			style.border_color = Color("#FF0055")

	if grade_label:
		grade_label.text = grade
		var grade_colors := {
			"S": Color("#FFE600"),
			"A": Color("#00FFFF"),
			"B": Color("#39FF14"),
			"C": Color("#FFA500"),
			"D": Color("#FF0055")
		}
		grade_label.modulate = Color.WHITE
		grade_label.add_theme_color_override("font_color", grade_colors.get(grade, Color.WHITE))

	if score_label:
		score_label.text = "TOTAL SCORE: %07d" % score

	if record_label:
		record_label.visible = is_record

	if missed_label:
		missed_label.text = "WORDS MISSED: %d" % words_missed
		missed_label.modulate = Color.WHITE
		missed_label.add_theme_color_override("font_color", Color("#FFE600"))

	if accuracy_label:
		accuracy_label.text = "VOCABULARY ACCURACY: %d%%" % int(accuracy * 100.0)

	if combo_label:
		combo_label.text = "MAX BRO-FACTOR: %dX" % max_combo

	var tree := _get_tree_safe()
	if tree:
		tree.paused = true

func _on_retry_pressed() -> void:
	var sfx = _get_sound_effects()
	if sfx:
		sfx.play_ui_click()
	Engine.time_scale = 1.0
	var tree := _get_tree_safe()
	if tree:
		tree.paused = false
		tree.change_scene_to_file("res://scenes/GameWorld.tscn")

func _on_menu_pressed() -> void:
	var sfx = _get_sound_effects()
	if sfx:
		sfx.play_ui_click()
	Engine.time_scale = 1.0
	var tree := _get_tree_safe()
	if tree:
		tree.paused = false
		tree.change_scene_to_file("res://scenes/MainMenu.tscn")

# scripts/CodexScreen.gd
extends Control

@onready var sector_filter: OptionButton = $VBox/TopBar/SectorFilter
@onready var progress_label: Label = $VBox/TopBar/ProgressLabel
@onready var close_btn: Button = $VBox/TopBar/CloseBtn
@onready var root_list_container: VBoxContainer = $VBox/Content/ScrollList/RootList

@onready var card_root: Label = $VBox/Content/DetailCard/VBox/RootLabel
@onready var card_origin: Label = $VBox/Content/DetailCard/VBox/OriginLabel
@onready var card_meaning: Label = $VBox/Content/DetailCard/VBox/MeaningLabel
@onready var card_examples: Label = $VBox/Content/DetailCard/VBox/ExamplesLabel
@onready var card_stats: Label = $VBox/Content/DetailCard/VBox/StatsLabel
@onready var card_mnemonic: Label = $VBox/Content/DetailCard/VBox/MnemonicLabel

var all_roots: Array = []
var selected_sector: int = 0 # 0 = All
var paused_game: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if close_btn:
		close_btn.pressed.connect(close_screen)

	setup_sector_filter()
	load_all_roots()
	populate_list()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_codex") or event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_screen()

func close_screen() -> void:
	if paused_game:
		var main_loop := Engine.get_main_loop()
		if main_loop is SceneTree:
			(main_loop as SceneTree).paused = false
		elif Engine.has_meta("active_tree"):
			(Engine.get_meta("active_tree") as SceneTree).paused = false
		if is_inside_tree() and has_node("/root/MusicManager"):
			get_node("/root/MusicManager").set_low_pass_enabled(false)
	queue_free()

func setup_sector_filter() -> void:
	if sector_filter:
		sector_filter.clear()
		sector_filter.add_item("All Sectors (48 Roots)", 0)
		sector_filter.add_item("Sector 01: Cytology & Bio-Genesis", 1)
		sector_filter.add_item("Sector 02: Astro & Celestial Dynamics", 2)
		sector_filter.add_item("Sector 03: Geo & Lithospheric Matrix", 3)
		sector_filter.add_item("Sector 04: Thermo & Quantum Energetics", 4)
		sector_filter.item_selected.connect(_on_sector_filter_changed)

func load_all_roots() -> void:
	all_roots.clear()
	var lm = get_node_or_null("/root/LexiconManager")
	if lm:
		all_roots = lm.roots_by_id.values()

func _on_sector_filter_changed(index: int) -> void:
	selected_sector = sector_filter.get_item_id(index)
	populate_list()

func populate_list() -> void:
	for c in root_list_container.get_children():
		c.queue_free()

	var gm = get_node_or_null("/root/GameManager")
	var unlocked_dict: Dictionary = gm.save_data.get("unlocked_roots", {}) if gm else {}
	var unlocked_count := 0

	for root_entry in all_roots:
		var sec_id: int = int(root_entry.get("sector", 1))
		var rid: String = root_entry.get("id", "")
		var is_unlocked: bool = unlocked_dict.has(rid)
		if is_unlocked:
			unlocked_count += 1

		if selected_sector != 0 and sec_id != selected_sector:
			continue

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 36)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var display_name: String = root_entry.get("root", rid)
		if is_unlocked:
			btn.text = "★ " + display_name + " — " + root_entry.get("meaning", "")
			btn.modulate = Color("#39FF14")
		else:
			btn.text = "🔒 " + display_name + " (Encounter to decode)"
			btn.modulate = Color(0.7, 0.7, 0.7)

		btn.pressed.connect(func(): display_root_card(root_entry, is_unlocked))
		root_list_container.add_child(btn)

	if progress_label:
		var pct := float(unlocked_count) / float(max(1, all_roots.size())) * 100.0
		progress_label.text = "CODEX DISCOVERY: %d / %d (%.1f%%)" % [unlocked_count, all_roots.size(), pct]

	if not all_roots.is_empty():
		display_root_card(all_roots[0], unlocked_dict.has(all_roots[0].get("id", "")))

func display_root_card(root_entry: Dictionary, is_unlocked: bool) -> void:
	var rid: String = root_entry.get("id", "")
	var gm = get_node_or_null("/root/GameManager")
	var rstat: Dictionary = gm.save_data.get("root_stats", {}).get(rid, {"hits": 0, "misses": 0}) if gm else {"hits": 0, "misses": 0}
	var hits := int(rstat.get("hits", 0))
	var misses := int(rstat.get("misses", 0))

	if card_root:
		card_root.text = root_entry.get("root", rid).to_upper()
	if card_origin:
		card_origin.text = "ORIGIN: " + root_entry.get("origin", "Greek/Latin")
	if card_meaning:
		card_meaning.text = "MEANING: " + root_entry.get("meaning", "")
	if card_examples:
		var ex: Array = root_entry.get("examples", [])
		card_examples.text = "SCIENTIFIC EXAMPLES: " + ", ".join(ex)
	if card_stats:
		card_stats.text = "STATS: %d HITS / %d MISSES (MASTERY SCORE: %d)" % [hits, misses, hits - misses]
	if card_mnemonic:
		if is_unlocked:
			card_mnemonic.text = "B.R.O. MNEMONIC:\n\"" + root_entry.get("mnemonic", "") + "\""
		else:
			card_mnemonic.text = "B.R.O. MNEMONIC:\n[ LOCKED — BLAST IN COMBAT TO REVEAL ]"

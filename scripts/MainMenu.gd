# scripts/MainMenu.gd
extends Control

@onready var main_menu_view: Control = $VBox/MainMenuView
@onready var sector_select_view: Control = $VBox/SectorSelectView
@onready var sector_cards_container: HBoxContainer = $VBox/SectorSelectView/SectorCards

@onready var new_game_btn: Button = $VBox/MainMenuView/MenuVBox/NewGameBtn
@onready var codex_btn: Button = $VBox/MainMenuView/MenuVBox/CodexBtn
@onready var settings_btn: Button = $VBox/MainMenuView/MenuVBox/SettingsBtn
@onready var quit_btn: Button = $VBox/MainMenuView/MenuVBox/QuitBtn
@onready var back_btn: Button = $VBox/SectorSelectView/TopBar/BackBtn
@onready var prev_page_btn: Button = $VBox/SectorSelectView/CarouselBar/PrevPageBtn
@onready var next_page_btn: Button = $VBox/SectorSelectView/CarouselBar/NextPageBtn
@onready var page_indicator: Label = $VBox/SectorSelectView/CarouselBar/PageIndicator

var current_page: int = 0

@onready var settings_modal: Control = $SettingsModal
@onready var master_slider: HSlider = $SettingsModal/Panel/VBox/MasterSlider
@onready var music_slider: HSlider = $SettingsModal/Panel/VBox/MusicSlider
@onready var sfx_slider: HSlider = $SettingsModal/Panel/VBox/SFXSlider
@onready var crt_check: CheckBox = $SettingsModal/Panel/VBox/CRTCheck
@onready var settings_close_btn: Button = $SettingsModal/Panel/VBox/CloseBtn

const SECTORS_DATA := [
	{"id": 1, "name": "SECTOR 01\nBIO-GENESIS", "desc": "Cytology & Cellular Dynamics", "color": "#39FF14", "unlocked": true},
	{"id": 2, "name": "SECTOR 02\nASTRO-DYNAMICS", "desc": "Celestial Bodies & Orbital Mechanics", "color": "#00F0FF", "unlocked": true},
	{"id": 3, "name": "SECTOR 03\nLITHOSPHERIC MATRIX", "desc": "Geology, Rocks & Crust Dynamics", "color": "#FFE600", "unlocked": true},
	{"id": 4, "name": "SECTOR 04\nQUANTUM ENERGETICS", "desc": "Thermodynamics & Light Radiation", "color": "#FF007F", "unlocked": true},
	{"id": 5, "name": "SECTOR 05\nGENOMIC CODE", "desc": "Genetics, DNA & Mutation Splicing", "color": "#A855F7", "unlocked": true},
	{"id": 6, "name": "SECTOR 06\nPARTICLE DYNAMICS", "desc": "Subatomic Matter, Quarks & Hadrons", "color": "#FF2A85", "unlocked": true},
	{"id": 7, "name": "SECTOR 07\nSONIC RESONANCE", "desc": "Acoustics, Wave Optics & Holography", "color": "#05FFA1", "unlocked": true},
	{"id": 8, "name": "SECTOR 08\nBIONIC AUTOMATA", "desc": "Cybernetics, Neural Links & Robotics", "color": "#FF6B00", "unlocked": true}
]

func _ready() -> void:
	if is_inside_tree() and has_node("/root/MusicManager"):
		get_node("/root/MusicManager").play_random_title_music()

	setup_sector_cards()

	if new_game_btn and not new_game_btn.pressed.is_connected(_on_new_game_pressed):
		new_game_btn.pressed.connect(_on_new_game_pressed)
	if codex_btn and not codex_btn.pressed.is_connected(_on_codex_pressed):
		codex_btn.pressed.connect(_on_codex_pressed)
	if settings_btn and not settings_btn.pressed.is_connected(_on_settings_pressed):
		settings_btn.pressed.connect(_on_settings_pressed)
	if quit_btn and not quit_btn.pressed.is_connected(_on_quit_pressed):
		quit_btn.pressed.connect(_on_quit_pressed)
	if back_btn and not back_btn.pressed.is_connected(_on_back_pressed):
		back_btn.pressed.connect(_on_back_pressed)
	if prev_page_btn and not prev_page_btn.pressed.is_connected(_on_prev_page_pressed):
		prev_page_btn.pressed.connect(_on_prev_page_pressed)
	if next_page_btn and not next_page_btn.pressed.is_connected(_on_next_page_pressed):
		next_page_btn.pressed.connect(_on_next_page_pressed)

	setup_settings_modal()
	show_main_menu()

func _on_quit_pressed() -> void:
	if is_inside_tree():
		get_tree().quit()

func show_main_menu() -> void:
	if main_menu_view:
		main_menu_view.visible = true
	if sector_select_view:
		sector_select_view.visible = false
	if is_inside_tree() and new_game_btn:
		new_game_btn.grab_focus()

func _on_new_game_pressed() -> void:
	if main_menu_view:
		main_menu_view.visible = false
	if sector_select_view:
		sector_select_view.visible = true

	# Focus the first unlocked sector card or back button
	if is_inside_tree():
		var card1: Control = sector_cards_container.get_node_or_null("Card1") if sector_cards_container else null
		if card1 and card1.focus_mode != Control.FOCUS_NONE:
			card1.grab_focus()
		elif back_btn:
			back_btn.grab_focus()

func _on_back_pressed() -> void:
	show_main_menu()

func set_page(page: int) -> void:
	current_page = clampi(page, 0, 1)
	setup_sector_cards()
	if is_inside_tree():
		var card1: Control = sector_cards_container.get_node_or_null("Card1") if sector_cards_container else null
		if card1 and card1.focus_mode != Control.FOCUS_NONE:
			card1.grab_focus()

func _on_prev_page_pressed() -> void:
	if current_page > 0:
		set_page(current_page - 1)
	else:
		set_page(1)

func _on_next_page_pressed() -> void:
	if current_page < 1:
		set_page(current_page + 1)
	else:
		set_page(0)

func setup_sector_cards() -> void:
	if sector_cards_container == null:
		return

	if page_indicator:
		if current_page == 0:
			page_indicator.text = "PAGE 1 / 2 : SECTORS 01–04"
		else:
			page_indicator.text = "PAGE 2 / 2 : SECTORS 05–08"

	var gm = get_node_or_null("/root/GameManager") if is_inside_tree() else null
	var sec_scores: Dictionary = gm.save_data.get("sector_scores", {}) if gm else {}
	var sec_grades: Dictionary = gm.save_data.get("sector_grades", {}) if gm else {}

	var card_nodes := sector_cards_container.get_children()
	var offset: int = current_page * 4
	for i in range(card_nodes.size()):
		var card: PanelContainer = card_nodes[i]
		var data_idx := offset + i
		if data_idx >= SECTORS_DATA.size():
			card.visible = false
			continue
		card.visible = true
		var data: Dictionary = SECTORS_DATA[data_idx]

		var sec_key := str(data["id"])
		var best_score: int = int(sec_scores.get(sec_key, 0))
		var best_grade: String = sec_grades.get(sec_key, "-")
		var is_unlocked: bool = bool(data.get("unlocked", false))

		var title_label: Label = card.get_node_or_null("VBox/Title")
		var desc_label: Label = card.get_node_or_null("VBox/Desc")
		var score_label: Label = card.get_node_or_null("VBox/Score")
		var grade_label: Label = card.get_node_or_null("VBox/Grade")

		if title_label:
			title_label.text = data["name"]
			if is_unlocked:
				title_label.modulate = Color(data["color"])
			else:
				title_label.modulate = Color(0.5, 0.5, 0.5, 0.7)

		if desc_label:
			desc_label.text = data["desc"]
			if not is_unlocked:
				desc_label.modulate = Color(0.5, 0.5, 0.5, 0.6)

		if score_label:
			if is_unlocked:
				score_label.text = "RECORD: %07d" % best_score
				score_label.modulate = Color(1, 0.9, 0, 1)
			else:
				score_label.text = "RECORD: LOCKED"
				score_label.modulate = Color(0.4, 0.4, 0.4, 0.6)

		if grade_label:
			if is_unlocked:
				grade_label.text = "RANK: " + best_grade
				var rank_colors = {"S": Color("#FFE600"), "A": Color("#39FF14"), "B": Color("#00F0FF"), "C": Color("#FF007F"), "D": Color.GRAY, "-": Color.DARK_GRAY}
				grade_label.modulate = rank_colors.get(best_grade, Color.WHITE)
			else:
				grade_label.text = "RANK: LOCKED"
				grade_label.modulate = Color(0.35, 0.35, 0.35, 0.6)

		var sec_id: int = data["id"]
		card.set_meta("is_locked", not is_unlocked)
		card.set_meta("card_clicked_callable", func(): start_sector(sec_id))

		if is_unlocked:
			card.focus_mode = Control.FOCUS_ALL
			card.mouse_filter = Control.MOUSE_FILTER_STOP
			card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		else:
			card.focus_mode = Control.FOCUS_NONE
			card.mouse_filter = Control.MOUSE_FILTER_IGNORE
			card.mouse_default_cursor_shape = Control.CURSOR_ARROW

		var synth_ui = get_node_or_null("/root/SynthwaveUI") if is_inside_tree() else null
		if synth_ui:
			synth_ui.apply_card_style(card, is_unlocked)

func start_sector(sector: int) -> void:
	if is_inside_tree() and has_node("/root/GameManager"):
		get_node("/root/GameManager").current_sector = sector
	if is_inside_tree():
		get_tree().change_scene_to_file("res://scenes/GameWorld.tscn")

func _on_codex_pressed() -> void:
	var codex_scn := load("res://scenes/CodexScreen.tscn") as PackedScene
	if codex_scn:
		var inst := codex_scn.instantiate()
		add_child(inst)

func _on_settings_pressed() -> void:
	if settings_modal:
		settings_modal.visible = true

func setup_settings_modal() -> void:
	if settings_modal == null:
		return
	settings_modal.visible = false

	var gm = get_node_or_null("/root/GameManager") if is_inside_tree() else null
	var settings: Dictionary = gm.save_data.get("settings", {}) if gm else {}

	if master_slider:
		master_slider.value = float(settings.get("master_volume", 1.0)) * 100.0
		master_slider.value_changed.connect(func(v): _update_volume("Master", v / 100.0))
	if music_slider:
		music_slider.value = float(settings.get("music_volume", 0.85)) * 100.0
		music_slider.value_changed.connect(func(v): _update_volume("Music", v / 100.0))
	if sfx_slider:
		sfx_slider.value = float(settings.get("sfx_volume", 0.9)) * 100.0
		sfx_slider.value_changed.connect(func(v): _update_volume("SFX", v / 100.0))
	if crt_check:
		crt_check.button_pressed = bool(settings.get("crt_scanlines", true))
		crt_check.toggled.connect(func(on):
			if gm:
				gm.save_data["settings"]["crt_scanlines"] = on
				gm.save_to_disk()
		)

	if settings_close_btn and not settings_close_btn.pressed.is_connected(_on_settings_close_pressed):
		settings_close_btn.pressed.connect(_on_settings_close_pressed)

func _on_settings_close_pressed() -> void:
	if settings_modal:
		settings_modal.visible = false

func _update_volume(bus_name: String, linear_val: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(max(0.0001, linear_val)))
	var gm = get_node_or_null("/root/GameManager") if is_inside_tree() else null
	if gm:
		var key := bus_name.to_lower() + "_volume"
		gm.save_data["settings"][key] = linear_val
		gm.save_to_disk()

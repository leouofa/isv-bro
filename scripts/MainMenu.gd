# scripts/MainMenu.gd
extends Control

@onready var sector_cards_container: HBoxContainer = $VBox/SectorCards
@onready var codex_btn: Button = $VBox/BottomBar/CodexBtn
@onready var settings_btn: Button = $VBox/BottomBar/SettingsBtn
@onready var quit_btn: Button = $VBox/BottomBar/QuitBtn

@onready var settings_modal: Control = $SettingsModal
@onready var master_slider: HSlider = $SettingsModal/Panel/VBox/MasterSlider
@onready var music_slider: HSlider = $SettingsModal/Panel/VBox/MusicSlider
@onready var sfx_slider: HSlider = $SettingsModal/Panel/VBox/SFXSlider
@onready var crt_check: CheckBox = $SettingsModal/Panel/VBox/CRTCheck
@onready var settings_close_btn: Button = $SettingsModal/Panel/VBox/CloseBtn

const SECTORS_DATA := [
	{"id": 1, "name": "SECTOR 01\nBIO-GENESIS", "desc": "Cytology & Cellular Dynamics", "color": "#39FF14"},
	{"id": 2, "name": "SECTOR 02\nASTRO-DYNAMICS", "desc": "Celestial Bodies & Orbital Mechanics", "color": "#00F0FF"},
	{"id": 3, "name": "SECTOR 03\nLITHOSPHERIC MATRIX", "desc": "Geology, Rocks & Crust Dynamics", "color": "#FFE600"},
	{"id": 4, "name": "SECTOR 04\nQUANTUM ENERGETICS", "desc": "Thermodynamics & Light Radiation", "color": "#FF007F"}
]

func _ready() -> void:
	if has_node("/root/MusicManager"):
		get_node("/root/MusicManager").play_sector_music(0, 0)

	setup_sector_cards()

	if codex_btn:
		codex_btn.pressed.connect(_on_codex_pressed)
	if settings_btn:
		settings_btn.pressed.connect(_on_settings_pressed)
	if quit_btn:
		quit_btn.pressed.connect(func(): get_tree().quit())

	setup_settings_modal()

func setup_sector_cards() -> void:
	if sector_cards_container == null:
		return

	var gm = get_node_or_null("/root/GameManager")
	var sec_scores: Dictionary = gm.save_data.get("sector_scores", {}) if gm else {}
	var sec_grades: Dictionary = gm.save_data.get("sector_grades", {}) if gm else {}

	var card_nodes := sector_cards_container.get_children()
	for i in range(SECTORS_DATA.size()):
		var data: Dictionary = SECTORS_DATA[i]
		var card: PanelContainer = card_nodes[i] if i < card_nodes.size() else null
		if card == null:
			continue

		var sec_key := str(data["id"])
		var best_score: int = int(sec_scores.get(sec_key, 0))
		var best_grade: String = sec_grades.get(sec_key, "-")

		var title_label: Label = card.get_node_or_null("VBox/Title")
		var desc_label: Label = card.get_node_or_null("VBox/Desc")
		var score_label: Label = card.get_node_or_null("VBox/Score")
		var grade_label: Label = card.get_node_or_null("VBox/Grade")
		var launch_btn: Button = card.get_node_or_null("VBox/LaunchBtn")

		if title_label:
			title_label.text = data["name"]
			title_label.modulate = Color(data["color"])
		if desc_label:
			desc_label.text = data["desc"]
		if score_label:
			score_label.text = "RECORD: %07d" % best_score
		if grade_label:
			grade_label.text = "RANK: " + best_grade
			var rank_colors = {"S": Color("#FFE600"), "A": Color("#39FF14"), "B": Color("#00F0FF"), "C": Color("#FF007F"), "D": Color.GRAY, "-": Color.DARK_GRAY}
			grade_label.modulate = rank_colors.get(best_grade, Color.WHITE)

		if launch_btn:
			var sec_id: int = data["id"]
			launch_btn.pressed.connect(func(): start_sector(sec_id))

func start_sector(sector: int) -> void:
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").current_sector = sector
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

	var gm = get_node_or_null("/root/GameManager")
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

	if settings_close_btn:
		settings_close_btn.pressed.connect(func(): settings_modal.visible = false)

func _update_volume(bus_name: String, linear_val: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(max(0.0001, linear_val)))
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		var key := bus_name.to_lower() + "_volume"
		gm.save_data["settings"][key] = linear_val
		gm.save_to_disk()

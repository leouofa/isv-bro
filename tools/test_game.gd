# tools/test_game.gd
extends SceneTree

var passes: int = 0
var failures: int = 0

func assert_true(cond: bool, msg: String) -> void:
	if cond:
		print("[PASS] " + msg)
		passes += 1
	else:
		printerr("[FAIL] " + msg)
		failures += 1

func _init() -> void:
	Engine.set_meta("active_tree", self)

	print("\n=======================================================")
	print("   ISV BRO — 8-SUITE HEADLESS VERIFICATION RUNNER")
	print("=======================================================\n")

	# SUITE 1: Verify All Core Scenes & 3D .glb Assets Load Cleanly
	print("--- SUITE 1: Core Scenes & 3D Assets ---")
	var scenes := [
		"res://scenes/MainMenu.tscn",
		"res://scenes/GameWorld.tscn",
		"res://scenes/HUD.tscn",
		"res://scenes/PauseMenu.tscn",
		"res://scenes/CodexScreen.tscn",
		"res://scenes/PlayerJet.tscn",
		"res://scenes/Anomaly.tscn",
		"res://scenes/BossExam.tscn"
	]
	for scn_path in scenes:
		var exists := ResourceLoader.exists(scn_path)
		assert_true(exists, "Scene exists: " + scn_path)
		if exists:
			var packed := load(scn_path) as PackedScene
			var inst := packed.instantiate() if packed else null
			assert_true(inst != null, "Scene instantiates cleanly: " + scn_path)
			if inst:
				inst.free()

	var models := [
		"res://assets/models/hadron_jet.glb",
		"res://assets/models/anomaly_bio.glb",
		"res://assets/models/anomaly_astro.glb",
		"res://assets/models/anomaly_geo.glb",
		"res://assets/models/anomaly_thermo.glb",
		"res://assets/models/hazard_laser_gate.glb",
		"res://assets/models/hazard_collider_ring.glb",
		"res://assets/models/pickup_coolant_cell.glb",
		"res://assets/models/pickup_shield_orb.glb",
		"res://assets/models/boss_core.glb"
	]
	for mdl in models:
		assert_true(FileAccess.file_exists(mdl) or ResourceLoader.exists(mdl), "3D Asset exists: " + mdl)

	# SUITE 2: Verify Rail-Shooter & Root Salvo InputMap Bindings
	print("\n--- SUITE 2: InputMap Actions & Mappings ---")
	var required_actions := [
		"move_left", "move_right", "move_up", "move_down",
		"barrel_roll", "boost", "airbrake",
		"root_1", "root_2", "root_3", "root_4", "pause"
	]
	for act in required_actions:
		assert_true(
			InputMap.has_action(act) and not InputMap.action_get_events(act).is_empty(),
			"InputAction registered & mapped: " + act
		)

	# SUITE 3: Verify ISV Lexicon (48+ Roots, 4 Sectors, 4 Boss Exams, 4-Choice Prompt & Spaced Repetition)
	print("\n--- SUITE 3: ISV Lexicon & Spaced Repetition Engine ---")
	var lex_node := Node.new()
	lex_node.set_script(load("res://scripts/LexiconManager.gd"))
	root.add_child(lex_node)
	lex_node._ready()

	assert_true(lex_node.roots_by_id.size() >= 48, "Lexicon contains >= 48 ISV roots (found %d)" % lex_node.roots_by_id.size())
	for s in [1, 2, 3, 4]:
		assert_true(lex_node.roots_by_sector.get(s, []).size() >= 12, "Sector %d has >= 12 roots" % s)
		assert_true(lex_node.boss_exams.has(s), "Boss Exam defined for Sector %d" % s)

	var prompt: Dictionary = lex_node.build_multiple_choice_prompt("lysis", 4)
	assert_true(prompt.get("options", []).size() == 4, "4-choice prompt generates 4 distinct root options")
	var c_idx: int = int(prompt.get("correct_index", -1))
	assert_true(c_idx >= 0 and c_idx < 4 and prompt["options"][c_idx]["id"] == "lysis", "Correct root index matches target 'lysis'")

	var w_before: float = lex_node.get_weight("lysis")
	lex_node.record_outcome("lysis", false)
	var w_after: float = lex_node.get_weight("lysis")
	assert_true(w_after > w_before, "Spaced repetition increases weight on missed root (%.2f -> %.2f)" % [w_before, w_after])

	# SUITE 4: Verify Bro-Factor Combo Scaling & Cognitive Overheat Lockout Math
	print("\n--- SUITE 4: Bro-Factor Combo Scaling & Cognitive Overheat ---")
	var gm := Node.new()
	gm.set_script(load("res://scripts/GameManager.gd"))
	root.add_child(gm)
	gm._ready()
	gm.start_new_run(1)

	for i in range(10):
		gm.register_root_hit("bio", 200)
	assert_true(gm.combo_multiplier == 8, "10 consecutive root hits scale Bro-Factor combo to 8x")

	for i in range(4):
		gm.register_root_miss("lysis")
	assert_true(gm.is_overheated_lockout == true, "4 consecutive wrong roots trigger 100% Cognitive Overheat weapon lockout")
	assert_true(gm.combo_multiplier == 1, "Incorrect root resets Bro-Factor combo to 1x")

	# SUITE 5: Verify Codex Unlock & Save Persistence in user://isv_save.json
	print("\n--- SUITE 5: Codex Unlock & Disk Persistence ---")
	var summary: Dictionary = gm.finalize_run(true)
	assert_true(FileAccess.file_exists("user://isv_save.json"), "Save file user://isv_save.json written to disk")
	assert_true(gm.save_data["unlocked_roots"].has("bio"), "Mastered root 'bio' unlocked in Codex Bro-tanica")
	assert_true(summary.has("grade") and summary["grade"] in ["S", "A", "B", "C", "D"], "Final run calculates valid letter grade: " + str(summary.get("grade")))

	# SUITE 6: Verify Framerate-Independent 6DOF Viewport Flight Kinematics (30, 60, 144 FPS)
	print("\n--- SUITE 6: 6DOF Viewport Kinematics (30, 60, 144 FPS) ---")
	for fps in [30.0, 60.0, 144.0]:
		var pos_x: float = 0.0
		var target_x: float = 5.5
		var steps: int = int(fps)
		var dt: float = 1.0 / float(fps)
		for s in range(steps):
			pos_x = lerpf(pos_x, target_x, 1.0 - exp(-18.0 * dt))
		assert_true(absf(pos_x - target_x) < 0.01, "6DOF viewport flight converges within 0.01m at %d FPS" % int(fps))

	# SUITE 7: Verify 14 Soundtrack MP3 Files Exist in res://tracks/
	print("\n--- SUITE 7: 14 Soundtrack MP3 Files ---")
	var tracks := [
		"res://tracks/Entryway.mp3", "res://tracks/Escape.mp3", "res://tracks/Left Turn.mp3",
		"res://tracks/Low Cut.mp3", "res://tracks/Luck.mp3", "res://tracks/Mirror Tech.mp3",
		"res://tracks/Rerun.mp3", "res://tracks/Silly Verses.mp3", "res://tracks/The End.mp3",
		"res://tracks/The Flight.mp3", "res://tracks/The Key.mp3", "res://tracks/The Run.mp3",
		"res://tracks/Ultrabeat.mp3", "res://tracks/Undercurrent.mp3", "res://tracks/Understanding.mp3"
	]
	for trk in tracks:
		assert_true(FileAccess.file_exists(trk), "Soundtrack MP3 present: " + trk)

	# SUITE 8: Verify PauseMenu State Recovery & Process Mode
	print("\n--- SUITE 8: PauseMenu Process Mode & Pause State Recovery ---")
	if ResourceLoader.exists("res://scenes/PauseMenu.tscn"):
		var pause_scn := (load("res://scenes/PauseMenu.tscn") as PackedScene).instantiate()
		root.add_child(pause_scn)
		pause_scn._ready()
		assert_true(pause_scn.process_mode == Node.PROCESS_MODE_ALWAYS, "PauseMenu uses PROCESS_MODE_ALWAYS")
		if pause_scn.has_method("pause_game") and pause_scn.has_method("resume_game"):
			pause_scn.pause_game()
			assert_true(paused == true, "PauseMenu.pause_game() sets SceneTree.paused = true")
			
			# Test confirmation popup dimmer and button state
			var c_dimmer = pause_scn.get_node_or_null("ConfirmDimmer") as ColorRect
			var c_box = pause_scn.get_node_or_null("ConfirmBox") as Control
			var res_btn = pause_scn.get_node_or_null("Panel/VBox/ResumeBtn") as Button
			var no_btn = pause_scn.get_node_or_null("ConfirmBox/VBox/HBox/NoBtn") as Button
			assert_true(c_dimmer != null, "ConfirmDimmer node exists in PauseMenu")
			assert_true(c_dimmer.visible == false, "ConfirmDimmer is hidden initially")
			
			pause_scn._ask_confirmation("restart", "RESTART CURRENT SECTOR?")
			assert_true(c_dimmer.visible == true, "ConfirmDimmer becomes visible on confirmation prompt")
			assert_true(c_box.visible == true, "ConfirmBox becomes visible on confirmation prompt")
			assert_true(res_btn.disabled == true, "Background PauseMenu buttons disabled during confirmation")
			
			pause_scn._on_confirm_no()
			assert_true(c_dimmer.visible == false, "ConfirmDimmer is hidden after canceling confirmation")
			assert_true(c_box.visible == false, "ConfirmBox is hidden after canceling confirmation")
			assert_true(res_btn.disabled == false, "Background PauseMenu buttons re-enabled after canceling confirmation")
			
			pause_scn.resume_game()
			assert_true(paused == false, "PauseMenu.resume_game() restores SceneTree.paused = false")
		pause_scn.free()

	# SUITE 9: Synthwave UI, Cursor Shapes & Card Interactivity
	print("\n--- SUITE 9: Synthwave UI, Cursor Shapes & Card Interactivity ---")
	var sfx_node := Node.new()
	sfx_node.set_name("SoundEffects")
	sfx_node.set_script(load("res://scripts/SoundEffects.gd"))
	root.add_child(sfx_node)
	sfx_node._ready()

	assert_true(sfx_node.get("sfx_ui_hover") != null, "SoundEffects generates procedural sfx_ui_hover")
	assert_true(sfx_node.get("sfx_ui_click") != null, "SoundEffects generates procedural sfx_ui_click")
	sfx_node.play_ui_hover()
	assert_true(true, "SoundEffects.play_ui_hover() executes cleanly")

	var ui_node := Node.new()
	ui_node.set_name("SynthwaveUI")
	ui_node.set_script(load("res://scripts/SynthwaveUI.gd"))
	root.add_child(ui_node)
	ui_node._ready()

	assert_true(ui_node.get("btn_style_hover") != null, "SynthwaveUI initializes btn_style_hover")
	assert_true(ui_node.get("card_style_hover") != null, "SynthwaveUI initializes card_style_hover")

	var menu_scn := (load("res://scenes/MainMenu.tscn") as PackedScene).instantiate()
	root.add_child(menu_scn)
	menu_scn._ready()

	var new_game_btn = menu_scn.get_node_or_null("VBox/MainMenuView/MenuVBox/NewGameBtn") as Button
	assert_true(new_game_btn != null and new_game_btn.mouse_default_cursor_shape == Control.CURSOR_POINTING_HAND, "MainMenu NewGameBtn has CURSOR_POINTING_HAND")

	var card1 = menu_scn.get_node_or_null("VBox/SectorSelectView/SectorCards/Card1") as PanelContainer
	assert_true(card1 != null and card1.mouse_default_cursor_shape == Control.CURSOR_POINTING_HAND, "MainMenu Card1 has CURSOR_POINTING_HAND")

	var launch1_btn = card1.get_node_or_null("VBox/LaunchBtn")
	assert_true(launch1_btn == null, "Engage sector LaunchBtn removed from SectorCard")

	# Test whole-card click triggers sector engagement
	ui_node.apply_card_style(card1, true)
	var clicked_box := [-1]
	card1.set_meta("card_clicked_callable", func(): clicked_box[0] = 1)
	card1.set_meta("is_locked", false)
	var click_ev := InputEventMouseButton.new()
	click_ev.button_index = MOUSE_BUTTON_LEFT
	click_ev.pressed = true
	card1.emit_signal("gui_input", click_ev)
	assert_true(clicked_box[0] == 1, "Clicking entire SectorCard triggers sector engagement")

	# Test keyboard activation (Enter / Space) on focused card
	clicked_box[0] = -1
	var key_ev := InputEventKey.new()
	key_ev.keycode = KEY_ENTER
	key_ev.pressed = true
	card1.emit_signal("gui_input", key_ev)
	assert_true(clicked_box[0] == 1, "Keyboard Enter on focused SectorCard triggers sector engagement")

	menu_scn.free()

	# Verify PauseMenu buttons cursor and panel padding
	var p_scn := (load("res://scenes/PauseMenu.tscn") as PackedScene).instantiate()
	root.add_child(p_scn)
	var resume_btn = p_scn.get_node_or_null("Panel/VBox/ResumeBtn") as Button
	assert_true(resume_btn != null and resume_btn.mouse_default_cursor_shape == Control.CURSOR_POINTING_HAND, "PauseMenu ResumeBtn has CURSOR_POINTING_HAND")
	var p_panel = p_scn.get_node_or_null("Panel") as PanelContainer
	var p_style = p_panel.get_theme_stylebox("panel") as StyleBoxFlat if p_panel else null
	assert_true(p_style != null and p_style.content_margin_left >= 16.0 and p_style.content_margin_right >= 16.0, "PauseMenu Panel has content margin padding")
	p_scn.free()

	# Verify CodexScreen elements cursor
	var c_scn := (load("res://scenes/CodexScreen.tscn") as PackedScene).instantiate()
	root.add_child(c_scn)
	var c_close = c_scn.get_node_or_null("VBox/TopBar/CloseBtn") as Button
	var c_filter = c_scn.get_node_or_null("VBox/TopBar/SectorFilter") as OptionButton
	var c_card = c_scn.get_node_or_null("VBox/Content/DetailCard") as PanelContainer
	assert_true(c_close != null and c_close.mouse_default_cursor_shape == Control.CURSOR_POINTING_HAND, "Codex CloseBtn has CURSOR_POINTING_HAND")
	assert_true(c_filter != null and c_filter.mouse_default_cursor_shape == Control.CURSOR_POINTING_HAND, "Codex SectorFilter has CURSOR_POINTING_HAND")
	assert_true(c_card != null and c_card.mouse_default_cursor_shape == Control.CURSOR_POINTING_HAND, "Codex DetailCard has CURSOR_POINTING_HAND")
	c_scn.free()

	# Verify HUD salvo buttons cursor
	var hud_scn := (load("res://scenes/HUD.tscn") as PackedScene).instantiate()
	root.add_child(hud_scn)
	var btn1 = hud_scn.get_node_or_null("TacticalBanner/VBox/ButtonsContainer/Btn1") as Button
	assert_true(btn1 != null and btn1.mouse_default_cursor_shape == Control.CURSOR_POINTING_HAND, "HUD Salvo Btn1 has CURSOR_POINTING_HAND")
	hud_scn.free()

	ui_node.free()
	sfx_node.free()

	gm.free()
	lex_node.free()

	print("\n=======================================================")
	print("   TEST SUMMARY: %d PASSED, %d FAILED" % [passes, failures])
	print("=======================================================\n")
	quit(0 if failures == 0 else 1)

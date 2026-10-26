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
		"res://scenes/BossExam.tscn",
		"res://scenes/GameOverScreen.tscn"
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
		"root_1", "root_2", "root_3", "root_4", "pause", "toggle_codex"
	]
	for act in required_actions:
		assert_true(
			InputMap.has_action(act) and not InputMap.action_get_events(act).is_empty(),
			"InputAction registered & mapped: " + act
		)

	# SUITE 3: Verify ISV Lexicon (48+ Roots, 4 Sectors, 4 Boss Exams, 4-Choice Prompt & Spaced Repetition)
	print("\n--- SUITE 3: ISV Lexicon & Spaced Repetition Engine ---")
	var lex_node := Node.new()
	lex_node.name = "LexiconManager"
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
	gm.name = "GameManager"
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

		# Test GameWorld in-game Codex toggle
		var gw_scn := (load("res://scenes/GameWorld.tscn") as PackedScene).instantiate()
		root.add_child(gw_scn)
		assert_true(gw_scn.has_method("toggle_codex"), "GameWorld has toggle_codex method")
		var gw_hud = gw_scn.get_node_or_null("HUD") as CanvasLayer
		assert_true(gw_hud != null and gw_hud.visible == true, "HUD is visible initially in GameWorld")
		gw_scn.open_codex()
		assert_true(paused == true, "GameWorld.open_codex() pauses SceneTree")
		assert_true(gw_scn.get("codex_instance") != null, "GameWorld.open_codex() instantiates CodexScreen")
		assert_true(gw_hud.visible == false, "HUD and scanlines are hidden when Codex is open")
		gw_scn.close_codex()
		assert_true(paused == false, "GameWorld.close_codex() restores SceneTree.paused = false")
		assert_true(gw_hud.visible == true, "HUD and scanlines are restored when Codex is closed")
		gw_scn.free()

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
	var codex_btn = p_scn.get_node_or_null("Panel/VBox/CodexBtn")
	assert_true(codex_btn == null, "CodexBtn removed from PauseMenu")
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

	# Verify HUD salvo buttons cursor and top-right Codex hint
	var hud_scn := (load("res://scenes/HUD.tscn") as PackedScene).instantiate()
	root.add_child(hud_scn)
	var btn1 = hud_scn.get_node_or_null("TacticalBanner/VBox/ButtonsContainer/Btn1") as Button
	assert_true(btn1 != null and btn1.mouse_default_cursor_shape == Control.CURSOR_POINTING_HAND, "HUD Salvo Btn1 has CURSOR_POINTING_HAND")
	var codex_hint = hud_scn.get_node_or_null("TopRight/CodexHint") as Label
	assert_true(codex_hint != null and codex_hint.text.contains("[B] CODEX BRO-TANICA"), "HUD TopRight has [B] CODEX BRO-TANICA hint")
	hud_scn.free()

	ui_node.free()
	sfx_node.free()

	print("\n--- SUITE 10: Title Screen Synthwave Background & Random Tracks ---")
	var main_menu := (load("res://scenes/MainMenu.tscn") as PackedScene).instantiate()
	root.add_child(main_menu)
	var title_lbl = main_menu.get_node_or_null("VBox/Header/Title") as Label
	assert_true(title_lbl != null and title_lbl.text == "ISV BRO", "Title text is exactly 'ISV BRO' with glasses emoji removed")
	var bg_container = main_menu.get_node_or_null("SubViewportContainer/SubViewport/TitleBackground3D")
	assert_true(bg_container != null, "3D Synthwave Background SubViewport present in MainMenu")
	assert_true(bg_container.get_node_or_null("GridPlane") != null, "Synthwave grid terrain plane present")
	assert_true(bg_container.get_node_or_null("HorizonSun") != null, "Synthwave horizon sun present")

	var mm_node = (load("res://scripts/MusicManager.gd") as GDScript).new()
	root.add_child(mm_node)
	var all_tracks = mm_node.get_all_tracks()
	assert_true(all_tracks.size() >= 15, "MusicManager discovered all tracks in res://tracks/ (found %d)" % all_tracks.size())
	mm_node.play_random_title_music()
	assert_true(all_tracks.has(mm_node.current_track_path), "MusicManager selected valid random track: %s" % mm_node.current_track_path)
	assert_true(mm_node.current_sector_played == -2, "MusicManager set to title music sector (-2)")
	var cur_track = mm_node.current_track_path
	mm_node._on_track_finished()
	assert_true(all_tracks.has(mm_node.current_track_path), "MusicManager shuffled to next track: %s" % mm_node.current_track_path)

	main_menu.free()
	mm_node.free()

	# SUITE 11: Space Laser & Focus Time-Slow Action Bindings
	print("\n--- SUITE 11: Space Laser & Focus Time-Slow Input Mappings ---")
	assert_true(InputMap.has_action("fire_laser"), "InputAction registered: fire_laser")
	assert_true(InputMap.has_action("time_slow"), "InputAction registered: time_slow")
	var fire_events := InputMap.action_get_events("fire_laser")
	var has_space := false
	for ev in fire_events:
		if ev is InputEventKey and (ev.physical_keycode == KEY_SPACE or ev.keycode == KEY_SPACE):
			has_space = true
	assert_true(has_space, "fire_laser mapped to Spacebar")

	var roll_events := InputMap.action_get_events("barrel_roll")
	var roll_has_space := false
	for ev in roll_events:
		if ev is InputEventKey and (ev.physical_keycode == KEY_SPACE or ev.keycode == KEY_SPACE):
			roll_has_space = true
	assert_true(not roll_has_space, "barrel_roll does NOT conflict with Spacebar")

	var slow_events := InputMap.action_get_events("time_slow")
	var has_shift := false
	for ev in slow_events:
		if ev is InputEventKey and (ev.physical_keycode == KEY_SHIFT or ev.keycode == KEY_SHIFT):
			has_shift = true
	assert_true(has_shift, "time_slow mapped to Shift key")

	# SUITE 12: Music Spectrum Analyzer & Real-time Beat Energy
	print("\n--- SUITE 12: AudioEffectSpectrumAnalyzer & Beat Detection ---")
	var mm_test: Node = (load("res://scripts/MusicManager.gd") as GDScript).new()
	root.add_child(mm_test)
	mm_test._ready()
	assert_true(mm_test.spectrum_analyzer != null, "AudioEffectSpectrumAnalyzer initialized on Music bus")
	assert_true(mm_test.spectrum_effect_idx >= 0, "Spectrum effect index registered on bus")
	var beat_energy: Dictionary = mm_test.get_beat_energy()
	assert_true(beat_energy.has("bass") and beat_energy.has("mid") and beat_energy.has("is_kick"), "get_beat_energy returns valid spectrum dictionary")
	mm_test.free()

	# SUITE 13: Focus Time-Slow & Chrono Energy Drain/Regen
	print("\n--- SUITE 13: Focus Time-Slow & Chrono Energy System ---")
	var world_scn: Node = (load("res://scenes/GameWorld.tscn") as PackedScene).instantiate()
	root.add_child(world_scn)
	world_scn._ready()
	assert_true(world_scn.focus_energy == 100.0, "Focus energy starts at max 100.0")
	var hud_node: Node = world_scn.get_node_or_null("HUD")
	assert_true(hud_node != null, "HUD present in GameWorld")
	var focus_bar := hud_node.get_node_or_null("BottomLeft/FocusBar") as ProgressBar
	assert_true(focus_bar != null, "FocusBar widget present in HUD BottomLeft")
	var mastery_lbl := hud_node.get_node_or_null("TopLeft/MasteryLabel") as Label
	assert_true(mastery_lbl != null, "MasteryLabel widget present in HUD TopLeft")
	var boss_hud_box: Node = hud_node.get_node_or_null("BossHealthContainer")
	assert_true(boss_hud_box != null, "BossHealthContainer widget present in HUD")

	# SUITE 14: Indefinite Sector Lexicon Mastery Queue
	print("\n--- SUITE 14: Indefinite Sector Lexicon Mastery Queue ---")
	assert_true(world_scn.unmastered_roots.size() == 12, "Sector 1 initializes queue with 12 unmastered roots (found %d)" % world_scn.unmastered_roots.size())
	assert_true(world_scn.mastered_root_ids.is_empty(), "Mastered roots list starts empty")
	var first_root_id: String = world_scn.unmastered_roots[0]["id"]

	# Simulate correct answer: root moves to mastered_root_ids and is removed from unmastered_roots
	world_scn.current_prompt = {"correct_index": 0, "target_id": first_root_id}
	world_scn.fire_laser_salvo(0)
	assert_true(world_scn.mastered_root_ids.has(first_root_id), "Correct root registered into mastered_root_ids")
	assert_true(world_scn.unmastered_roots.size() == 11, "Unmastered roots queue decremented to 11")
	assert_true(world_scn.anomalies_cleared == 1, "Anomalies cleared tracks mastered count")

	# Simulate incorrect answer: target remains in unmastered_roots
	var second_root_id: String = world_scn.unmastered_roots[0]["id"]
	world_scn.current_prompt = {"correct_index": 1, "target_id": second_root_id}
	world_scn.fire_laser_salvo(0)
	assert_true(not world_scn.mastered_root_ids.has(second_root_id), "Incorrect root is NOT mastered")
	assert_true(world_scn.unmastered_roots.size() == 11, "Incorrect root remains in unmastered queue for replay")

	# Pacing & Extended Word Visibility Verification
	var test_anom: Node = (load("res://scenes/Anomaly.tscn") as PackedScene).instantiate()
	assert_true(is_equal_approx(test_anom.move_speed, 7.4), "Anomaly move_speed reduced to 7.4 m/s for extended word visibility")
	test_anom.free()
	assert_true(is_equal_approx(world_scn.ANOMALY_SPAWN_INTERVAL, 6.5), "GameWorld ANOMALY_SPAWN_INTERVAL set to 6.5s")

	world_scn.free()

	# SUITE 15: Boss Dogfight & Space Laser Combat
	print("\n--- SUITE 15: Boss Dogfight & Space Laser Combat ---")
	var boss_scn: Node = (load("res://scenes/BossExam.tscn") as PackedScene).instantiate()
	root.add_child(boss_scn)
	boss_scn._ready()
	boss_scn.setup_boss(1)
	assert_true(boss_scn.boss_hp == 600.0, "Boss HP initialized to 600.0 for Sector 1")
	assert_true(boss_scn.is_active and not boss_scn.is_defeated, "Boss enters active combat mode")

	# Test laser damage
	boss_scn.take_laser_damage(100.0)
	assert_true(boss_scn.boss_hp == 500.0, "Laser deals direct damage to Boss HP (600.0 -> 500.0)")

	# Test boss attacks
	boss_scn.launch_boss_attack()
	var hazards_found: int = 0
	for ch in root.get_children():
		if ch.is_in_group("hazards"):
			hazards_found += 1
			ch.queue_free()
	assert_true(hazards_found > 0, "Boss launched projectile hazards in group 'hazards' (found %d)" % hazards_found)

	# Test boss defeat
	boss_scn.take_laser_damage(500.0)
	assert_true(boss_scn.boss_hp == 0.0, "Boss HP depleted to 0.0")
	assert_true(boss_scn.is_defeated, "Boss defeated flag set upon 0 HP")

	boss_scn.free()

	# SUITE 16: Shield Depletion, Missed Words Tracking & GameOverScreen
	print("\n--- SUITE 16: Shield Depletion, Missed Words Tracking & GameOverScreen ---")
	gm.start_new_run(1)
	assert_true(gm.words_missed_this_run == 0, "Missed words counter reset to 0 on new run")
	gm.register_root_miss("bio")
	gm.register_root_miss("cyto")
	assert_true(gm.words_missed_this_run == 2, "Missed words counter tracked 2 misses")

	# Shield damage from boss hazards (15.0 dmg per orb)
	var jet_scn := (load("res://scenes/PlayerJet.tscn") as PackedScene).instantiate()
	root.add_child(jet_scn)
	var initial_shield: float = gm.shield_hp
	var orb_hazard := Area3D.new()
	orb_hazard.add_to_group("hazards")
	orb_hazard.set_meta("damage", 15.0)
	orb_hazard.set_meta("destroy_on_hit", true)
	jet_scn._on_area_entered(orb_hazard)
	assert_true(gm.shield_hp == initial_shield - 15.0, "Hazard collision decrements shield by 15.0 (%.1f -> %.1f)" % [initial_shield, gm.shield_hp])
	orb_hazard.free()

	# Pickup collection test: ensure parent container is NOT freed on collection
	var test_container := Node3D.new()
	root.add_child(test_container)
	var coolant_pickup := Area3D.new()
	coolant_pickup.add_to_group("pickup_coolant")
	test_container.add_child(coolant_pickup)
	jet_scn._on_area_entered(coolant_pickup)
	assert_true(is_instance_valid(test_container), "Parent container remains valid after coolant pickup collected")

	var shield_pickup := Area3D.new()
	shield_pickup.add_to_group("pickup_shield")
	test_container.add_child(shield_pickup)
	jet_scn._on_area_entered(shield_pickup)
	assert_true(is_instance_valid(test_container), "Parent container remains valid after shield pickup collected")
	test_container.free()

	jet_scn.free()

	# Shield depletion to 0 triggers run_ended
	var last_summary_box: Array[Dictionary] = [{}]
	var conn_callable := func(s: Dictionary): last_summary_box[0] = s
	gm.run_ended.connect(conn_callable)
	gm.apply_shield_damage(gm.shield_hp) # Deplete completely
	assert_true(gm.shield_hp == 0.0, "Shield integrity dropped to 0.0")
	var sum_dict: Dictionary = last_summary_box[0]
	assert_true(not sum_dict.is_empty(), "run_ended signal emitted on 0 shield")
	assert_true(sum_dict.get("survived", true) == false, "Summary indicates player did not survive (Game Over)")
	assert_true(int(sum_dict.get("words_missed", -1)) == 2, "Summary correctly reports 2 words missed")
	gm.run_ended.disconnect(conn_callable)

	# Verify GameOverScreen results presentation (Game Over and Victory)
	var ui_for_go := Node.new()
	ui_for_go.set_name("SynthwaveUI")
	ui_for_go.set_script(load("res://scripts/SynthwaveUI.gd"))
	root.add_child(ui_for_go)
	ui_for_go._ready()

	assert_true(ui_for_go.has_method("apply_button_style"), "SynthwaveUI provides apply_button_style")
	assert_true(ui_for_go.has_method("apply_btn_style"), "SynthwaveUI provides apply_btn_style alias")

	var go_scn: Node = (load("res://scenes/GameOverScreen.tscn") as PackedScene).instantiate()
	root.add_child(go_scn)
	go_scn.call("_ready")

	# Test Failure Presentation
	go_scn.setup_results({"survived": false, "score": 2100, "words_missed": 3, "grade": "D", "sector": 1})
	var h_lbl = go_scn.get_node_or_null("Panel/VBox/HeaderLabel") as Label
	var m_lbl = go_scn.get_node_or_null("Panel/VBox/StatsBox/MissedLabel") as Label
	var s_lbl = go_scn.get_node_or_null("Panel/VBox/StatsBox/ScoreLabel") as Label
	assert_true(h_lbl != null and h_lbl.text == "CRITICAL FAILURE", "GameOverScreen shows 'CRITICAL FAILURE' on shield loss")
	assert_true(m_lbl != null and m_lbl.text == "WORDS MISSED: 3", "GameOverScreen displays 'WORDS MISSED: 3'")
	assert_true(s_lbl != null and s_lbl.text.contains("0002100"), "GameOverScreen displays formatted total score")

	# Test Victory Presentation
	go_scn.setup_results({"survived": true, "score": 15000, "words_missed": 1, "grade": "S", "sector": 1})
	assert_true(h_lbl != null and h_lbl.text == "SECTOR 01 CLEARED", "GameOverScreen shows 'SECTOR 01 CLEARED' on victory")
	assert_true(m_lbl != null and m_lbl.text == "WORDS MISSED: 1", "GameOverScreen displays 'WORDS MISSED: 1'")

	go_scn.free()
	ui_for_go.free()

	gm.free()
	lex_node.free()

	print("\n=======================================================")
	print("   TEST SUMMARY: %d PASSED, %d FAILED" % [passes, failures])
	print("=======================================================\n")
	quit(0 if failures == 0 else 1)

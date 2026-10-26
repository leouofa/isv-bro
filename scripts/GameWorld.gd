# scripts/GameWorld.gd
extends Node3D

@export var sector_id: int = 1
@export var total_anomalies: int = 12

var active_anomalies: Array[Node3D] = []
var locked_target: Node3D = null
var current_prompt: Dictionary = {}

var tunnel_rings: Array[Node3D] = []
const RING_SPACING := 14.0
const NUM_RINGS := 10
const TUNNEL_SPEED := 24.0

var anomalies_spawned: int = 0
var anomalies_cleared: int = 0
var is_boss_active: bool = false
var boss_instance: Node3D = null

var unmastered_roots: Array[Dictionary] = []
var mastered_root_ids: Array[String] = []
var total_sector_roots: int = 12

var spawn_timer: float = 0.0
const ANOMALY_SPAWN_INTERVAL: float = 6.5
var hazard_timer: float = 0.0
const FALLBACK_HAZARD_INTERVAL: float = 5.5

var focus_energy: float = 100.0
const MAX_FOCUS_ENERGY: float = 100.0
const FOCUS_DRAIN_RATE: float = 28.0
const FOCUS_REGEN_RATE: float = 18.0
var is_focus_active: bool = false

var space_laser_cooldown: float = 0.0

@onready var camera: Camera3D = $Camera3D
@onready var player_jet: CharacterBody3D = $PlayerJet
@onready var hud: CanvasLayer = $HUD
@onready var rings_container: Node3D = $TunnelRings
@onready var objects_container: Node3D = $DynamicObjects
@onready var laser_mesh: MeshInstance3D = $LaserBeam
@onready var codex_layer: CanvasLayer = $CodexLayer

var codex_instance: Node = null

var ANOMALY_SCENE: PackedScene = load("res://scenes/Anomaly.tscn")
var BOSS_SCENE: PackedScene = load("res://scenes/BossExam.tscn")
var RING_MODEL: PackedScene = load("res://assets/models/hazard_collider_ring.glb")
var HAZARD_GATE: PackedScene = load("res://assets/models/hazard_laser_gate.glb")
var PICKUP_COOLANT: PackedScene = load("res://assets/models/pickup_coolant_cell.glb")
var PICKUP_SHIELD: PackedScene = load("res://assets/models/pickup_shield_orb.glb")
var GAMEOVER_SCENE: PackedScene = load("res://scenes/GameOverScreen.tscn")

func _ready() -> void:
	Engine.time_scale = 1.0

	if is_inside_tree() and has_node("/root/GameManager"):
		sector_id = get_node("/root/GameManager").current_sector
		get_node("/root/GameManager").start_new_run(sector_id)
		get_node("/root/GameManager").run_ended.connect(_on_run_ended)

	if is_inside_tree() and has_node("/root/MusicManager"):
		get_node("/root/MusicManager").play_sector_music(sector_id, 0)

	if player_jet and player_jet.has_signal("jet_damaged"):
		player_jet.jet_damaged.connect(func(_amount): shake_camera())

	setup_lexicon_queue()
	setup_tunnel()
	if laser_mesh:
		laser_mesh.visible = false

func _exit_tree() -> void:
	Engine.time_scale = 1.0

func _get_lexicon_manager() -> Node:
	if is_inside_tree() and has_node("/root/LexiconManager"):
		return get_node("/root/LexiconManager")
	var tree := _get_tree_safe()
	if tree and tree.root and tree.root.has_node("LexiconManager"):
		return tree.root.get_node("LexiconManager")
	return null

func _get_objects_container() -> Node3D:
	if is_instance_valid(objects_container):
		return objects_container
	if is_inside_tree() and has_node("DynamicObjects"):
		var dyn = get_node("DynamicObjects") as Node3D
		if is_instance_valid(dyn):
			objects_container = dyn
			return objects_container
	var new_dyn := Node3D.new()
	new_dyn.name = "DynamicObjects"
	add_child(new_dyn)
	objects_container = new_dyn
	return objects_container

func setup_lexicon_queue() -> void:
	unmastered_roots.clear()
	mastered_root_ids.clear()
	var lm = _get_lexicon_manager()
	var sec_roots: Array = []
	if lm:
		sec_roots = lm.roots_by_sector.get(sector_id, [])
		if sec_roots.is_empty():
			sec_roots = lm.roots_by_id.values()
	else:
		var tmp_lex = load("res://scripts/LexiconManager.gd").new()
		sec_roots = tmp_lex.roots_by_sector.get(sector_id, [])
		if sec_roots.is_empty():
			sec_roots = tmp_lex.roots_by_id.values()

	for r in sec_roots:
		unmastered_roots.append(r)
	total_sector_roots = unmastered_roots.size()

	total_anomalies = total_sector_roots
	anomalies_cleared = 0
	if hud and hud.has_method("update_mastery"):
		hud.update_mastery(0, total_sector_roots)

func setup_tunnel() -> void:
	if RING_MODEL == null:
		return
	for i in range(NUM_RINGS):
		var ring := RING_MODEL.instantiate() as Node3D
		ring.position = Vector3(0, 0, -float(i) * RING_SPACING)
		rings_container.add_child(ring)
		tunnel_rings.append(ring)

func _physics_process(delta: float) -> void:
	# Scroll particle tunnel rings
	for ring in tunnel_rings:
		ring.position.z += TUNNEL_SPEED * delta
		if ring.position.z > 12.0:
			ring.position.z -= float(NUM_RINGS) * RING_SPACING

	# Shift Focus (Time-Slow)
	var can_focus := focus_energy > 5.0
	if Input.is_action_pressed("time_slow") and can_focus:
		is_focus_active = true
		var unscaled_dt := delta / (Engine.time_scale if Engine.time_scale > 0.05 else 1.0)
		focus_energy = max(0.0, focus_energy - FOCUS_DRAIN_RATE * unscaled_dt)
		Engine.time_scale = 0.32
		if has_node("/root/MusicManager"):
			get_node("/root/MusicManager").set_low_pass_enabled(true)
	else:
		if is_focus_active:
			is_focus_active = false
			Engine.time_scale = 1.0
			var gm = get_node_or_null("/root/GameManager")
			if gm and not gm.is_overheated_lockout and has_node("/root/MusicManager"):
				get_node("/root/MusicManager").set_low_pass_enabled(false)
		else:
			Engine.time_scale = 1.0
		focus_energy = min(MAX_FOCUS_ENERGY, focus_energy + FOCUS_REGEN_RATE * delta)

	if hud and hud.has_method("update_focus"):
		hud.update_focus(focus_energy, MAX_FOCUS_ENERGY)

	# Wave Spawning (indefinite until all sector vocabulary is cleared)
	if not is_boss_active:
		spawn_timer += delta
		if spawn_timer >= ANOMALY_SPAWN_INTERVAL and not unmastered_roots.is_empty() and active_anomalies.size() < 2:
			spawn_timer = 0.0
			spawn_anomaly()

		# Procedural soundtrack-driven obstacle generation
		var spawned_by_beat := false
		if has_node("/root/MusicManager"):
			var beat_data: Dictionary = get_node("/root/MusicManager").get_beat_energy()
			if beat_data.get("is_kick", false):
				spawn_procedural_obstacle(beat_data)
				spawned_by_beat = true

		hazard_timer += delta
		if not spawned_by_beat and hazard_timer >= FALLBACK_HAZARD_INTERVAL:
			hazard_timer = 0.0
			spawn_procedural_obstacle()

		if unmastered_roots.is_empty() and active_anomalies.is_empty():
			spawn_boss()

	# Lock-on Targeting
	update_lock_on_target()

	# Project reticle to HUD
	if hud and hud.has_method("update_reticle_projection"):
		hud.update_reticle_projection(camera, locked_target)

	# Combat Inputs
	if is_boss_active and is_instance_valid(boss_instance):
		handle_boss_combat(delta)
	else:
		handle_root_inputs()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_codex"):
		var pause_menu = get_node_or_null("PauseMenu")
		if pause_menu and pause_menu.visible:
			return
		toggle_codex()
		get_viewport().set_input_as_handled()

func toggle_codex() -> void:
	if is_instance_valid(codex_instance):
		close_codex()
	else:
		open_codex()

func _get_tree_safe() -> SceneTree:
	if is_inside_tree() and get_tree():
		return get_tree()
	var main_loop := Engine.get_main_loop()
	if main_loop is SceneTree:
		return main_loop as SceneTree
	if Engine.has_meta("active_tree"):
		return Engine.get_meta("active_tree") as SceneTree
	return null

func _get_hud() -> CanvasLayer:
	if hud != null:
		return hud
	return get_node_or_null("HUD") as CanvasLayer

func _get_codex_layer() -> CanvasLayer:
	if codex_layer != null:
		return codex_layer
	return get_node_or_null("CodexLayer") as CanvasLayer

func open_codex() -> void:
	var pause_menu = get_node_or_null("PauseMenu")
	if pause_menu and pause_menu.visible:
		return
	var codex_scn := load("res://scenes/CodexScreen.tscn") as PackedScene
	if codex_scn:
		var inst = codex_scn.instantiate()
		inst.set("paused_game", true)
		codex_instance = inst
		var h := _get_hud()
		if h:
			h.visible = false
		inst.tree_exited.connect(_on_codex_tree_exited)
		var cl := _get_codex_layer()
		if cl:
			cl.add_child(inst)
		else:
			add_child(inst)
		Engine.time_scale = 1.0
		var tree := _get_tree_safe()
		if tree:
			tree.paused = true
		if is_inside_tree() and has_node("/root/MusicManager"):
			get_node("/root/MusicManager").set_low_pass_enabled(true)

func close_codex() -> void:
	if is_instance_valid(codex_instance):
		if codex_instance.has_method("close_screen"):
			codex_instance.close_screen()
		else:
			codex_instance.queue_free()
		codex_instance = null
	var h := _get_hud()
	if h:
		h.visible = true

func _on_codex_tree_exited() -> void:
	codex_instance = null
	var h := _get_hud()
	if h:
		h.visible = true

func update_lock_on_target() -> void:
	# Clean dead targets
	active_anomalies = active_anomalies.filter(func(a): return is_instance_valid(a) and not a.is_queued_for_deletion())

	if is_boss_active and is_instance_valid(boss_instance):
		if locked_target != boss_instance:
			locked_target = boss_instance
			if has_node("/root/SoundEffects"):
				get_node("/root/SoundEffects").play_lock_on()
		return

	if active_anomalies.is_empty():
		locked_target = null
		current_prompt = {}
		if hud and hud.has_method("clear_prompt"):
			hud.clear_prompt()
		return

	# Lock onto nearest anomaly in front of jet
	var closest: Node3D = null
	var min_dist := 9999.0
	for anom in active_anomalies:
		if anom.position.z < player_jet.position.z + 2.0: # In front of jet
			var dist := player_jet.global_position.distance_to(anom.global_position)
			if dist < min_dist:
				min_dist = dist
				closest = anom

	if closest != locked_target:
		locked_target = closest
		if locked_target != null:
			if has_node("/root/SoundEffects"):
				get_node("/root/SoundEffects").play_lock_on()
			current_prompt = locked_target.get("prompt_data")
			if hud and hud.has_method("display_prompt"):
				hud.display_prompt(current_prompt)

func handle_root_inputs() -> void:
	if locked_target == null or current_prompt.is_empty():
		return

	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.is_overheated_lockout:
		return

	var selected_idx := -1
	if Input.is_action_just_pressed("root_1"):
		selected_idx = 0
	elif Input.is_action_just_pressed("root_2"):
		selected_idx = 1
	elif Input.is_action_just_pressed("root_3"):
		selected_idx = 2
	elif Input.is_action_just_pressed("root_4"):
		selected_idx = 3

	if selected_idx != -1:
		fire_laser_salvo(selected_idx)

func fire_laser_salvo(selected_index: int) -> void:
	if locked_target == null and current_prompt.is_empty():
		return

	# SFX and visual laser beam
	if is_inside_tree() and has_node("/root/SoundEffects"):
		get_node("/root/SoundEffects").play_laser_salvo()

	if is_instance_valid(locked_target) and player_jet:
		draw_laser_beam(player_jet.global_position, locked_target.global_position)

	var correct_idx: int = int(current_prompt.get("correct_index", -1))
	var target_id: String = current_prompt.get("target_id", "")

	if selected_index == correct_idx:
		# Hit!
		if is_inside_tree() and has_node("/root/GameManager"):
			var pts: int = get_node("/root/GameManager").register_root_hit(target_id)
			if pts > 200:
				if is_inside_tree() and has_node("/root/SoundEffects"):
					get_node("/root/SoundEffects").play_combo_up(get_node("/root/GameManager").combo_multiplier)
			if get_node("/root/GameManager").combo_multiplier >= 8:
				get_node("/root/GameManager").bro_callout.emit("HYPE_COMBO", "RADICAL 8X ETYMOLOGY, BRO!!")

		# Record root as mastered and remove from unmastered queue
		if not mastered_root_ids.has(target_id):
			mastered_root_ids.append(target_id)
			for i in range(unmastered_roots.size() - 1, -1, -1):
				if unmastered_roots[i]["id"] == target_id:
					unmastered_roots.remove_at(i)
					break
			anomalies_cleared = mastered_root_ids.size()
			if hud and hud.has_method("update_mastery"):
				hud.update_mastery(mastered_root_ids.size(), total_sector_roots)

		if is_instance_valid(locked_target):
			locked_target.detonate()
			locked_target = null
	else:
		# Miss! (Root stays in unmastered_roots to be encountered again)
		if is_inside_tree() and has_node("/root/SoundEffects"):
			get_node("/root/SoundEffects").play_error_buzz()
		if is_inside_tree() and has_node("/root/GameManager"):
			get_node("/root/GameManager").register_root_miss(target_id)
		shake_camera()

func handle_boss_combat(delta: float) -> void:
	if space_laser_cooldown > 0.0:
		space_laser_cooldown -= delta

	if Input.is_action_pressed("fire_laser") and space_laser_cooldown <= 0.0:
		space_laser_cooldown = 0.16 # Rapid fire Space laser!
		fire_space_laser_at_boss()

func fire_space_laser_at_boss() -> void:
	if not is_instance_valid(boss_instance):
		return

	if has_node("/root/SoundEffects"):
		get_node("/root/SoundEffects").play_laser_salvo()

	draw_laser_beam(player_jet.global_position, boss_instance.global_position)
	if boss_instance.has_method("take_laser_damage"):
		boss_instance.take_laser_damage(26.0)
	elif boss_instance.has_method("register_hit"):
		boss_instance.register_hit()

func draw_laser_beam(start_pos: Vector3, end_pos: Vector3) -> void:
	if laser_mesh == null:
		return
	laser_mesh.visible = true
	var dir := end_pos - start_pos
	laser_mesh.global_position = start_pos + (dir * 0.5)
	laser_mesh.look_at(end_pos, Vector3.UP)
	laser_mesh.scale = Vector3(0.12, 0.12, dir.length())

	var tween := create_tween()
	tween.tween_property(laser_mesh, "scale:x", 0.0, 0.12)
	tween.tween_callback(func(): laser_mesh.visible = false)

func shake_camera() -> void:
	var tween := create_tween()
	tween.tween_property(camera, "position:x", 0.35, 0.04)
	tween.tween_property(camera, "position:x", -0.35, 0.04)
	tween.tween_property(camera, "position:x", 0.0, 0.04)

func spawn_anomaly() -> void:
	if ANOMALY_SCENE == null or unmastered_roots.is_empty():
		return
	anomalies_spawned += 1
	var anom := ANOMALY_SCENE.instantiate() as Node3D
	var spawn_x := randf_range(-4.5, 4.5)
	var spawn_y := randf_range(-2.5, 2.5)
	anom.position = Vector3(spawn_x, spawn_y, -55.0)

	# Pick target root from unmastered roots with spaced repetition weighting
	var target_root := {}
	var lm = get_node_or_null("/root/LexiconManager")
	if lm:
		var total_w := 0.0
		for item in unmastered_roots:
			total_w += lm.get_weight(item["id"])
		var roll := randf() * total_w
		var accum := 0.0
		for item in unmastered_roots:
			accum += lm.get_weight(item["id"])
			if roll <= accum:
				target_root = item
				break
		if target_root.is_empty():
			target_root = unmastered_roots[0]
	else:
		target_root = unmastered_roots[0]

	_get_objects_container().add_child(anom)
	anom.setup(target_root, sector_id)
	active_anomalies.append(anom)
	anom.destroyed.connect(_on_anomaly_destroyed)

func _on_anomaly_destroyed(anom: Node3D) -> void:
	active_anomalies.erase(anom)
	if locked_target == anom:
		locked_target = null

func spawn_procedural_obstacle(beat_data: Dictionary = {}) -> void:
	var bass: float = beat_data.get("bass", 0.1)
	var mid: float = beat_data.get("mid", 0.1)
	var roll := randf()

	# High bass kicks or obstacle roll triggers laser gate hazards
	if (bass > 0.16 or roll < 0.65) and HAZARD_GATE:
		var gate := Area3D.new()
		gate.add_to_group("hazards")
		gate.collision_layer = 2
		gate.collision_mask = 1
		gate.set_meta("damage", 25.0)
		var model: Node3D = HAZARD_GATE.instantiate()
		gate.add_child(model)
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(3.2, 0.6, 0.6)
		shape.shape = box
		gate.add_child(shape)

		var pos_x := randf_range(-3.5, 3.5)
		var pos_y := randf_range(-2.0, 2.0)
		gate.position = Vector3(pos_x, pos_y, -60.0)
		if mid > 0.14:
			gate.rotation.z = PI * 0.5
		_get_objects_container().add_child(gate)

		var tw := create_tween()
		tw.tween_property(gate, "position:z", 10.0, 3.5)
		tw.tween_callback(gate.queue_free)
	elif roll < 0.82 and PICKUP_COOLANT:
		_spawn_pickup(PICKUP_COOLANT, "pickup_coolant")
	elif PICKUP_SHIELD:
		_spawn_pickup(PICKUP_SHIELD, "pickup_shield")

func _spawn_pickup(scene: PackedScene, group_name: String) -> void:
	if scene == null:
		return
	var item := Area3D.new()
	item.add_to_group(group_name)
	item.collision_layer = 2
	item.collision_mask = 1
	var model: Node3D = scene.instantiate()
	item.add_child(model)
	var shape := CollisionShape3D.new()
	var sp := SphereShape3D.new()
	sp.radius = 1.0
	shape.shape = sp
	item.add_child(shape)
	item.position = Vector3(randf_range(-4.0, 4.0), randf_range(-2.0, 2.0), -55.0)
	_get_objects_container().add_child(item)

	var tw := create_tween()
	tw.tween_property(item, "position:z", 10.0, 3.8)
	tw.tween_callback(item.queue_free)

func spawn_boss() -> void:
	if BOSS_SCENE == null:
		return
	is_boss_active = true
	if hud and hud.has_method("clear_prompt"):
		hud.clear_prompt()

	boss_instance = BOSS_SCENE.instantiate() as Node3D
	boss_instance.position = Vector3(0, 1.0, -28.0)
	_get_objects_container().add_child(boss_instance)
	boss_instance.setup_boss(sector_id)
	boss_instance.boss_defeated.connect(_on_boss_defeated)

	var boss_name: String = boss_instance.boss_data.get("boss_name", "ANOMALY OVERLORD")
	if hud and hud.has_method("show_boss_health"):
		hud.show_boss_health(boss_name, boss_instance.boss_hp, boss_instance.boss_max_hp)

	if boss_instance.has_signal("boss_hp_changed"):
		boss_instance.boss_hp_changed.connect(_on_boss_hp_changed)

	if has_node("/root/GameManager"):
		get_node("/root/GameManager").bro_callout.emit(
			"BOSS_ALERT",
			"FINAL EXAM BOSS DETECTED! AVOID ATTACKS AND FIRE LASERS WITH [SPACE]!"
		)

func _on_boss_hp_changed(current_hp: float, max_hp: float) -> void:
	if hud and hud.has_method("update_boss_hp"):
		hud.update_boss_hp(current_hp, max_hp)

func _on_boss_defeated() -> void:
	Engine.time_scale = 1.0
	if hud and hud.has_method("hide_boss_health"):
		hud.hide_boss_health()
	if is_inside_tree() and has_node("/root/GameManager"):
		get_node("/root/GameManager").finalize_run(true)

func _on_run_ended(summary: Dictionary) -> void:
	Engine.time_scale = 1.0
	if hud and hud.has_method("hide_boss_health"):
		hud.hide_boss_health()

	if GAMEOVER_SCENE:
		var go := GAMEOVER_SCENE.instantiate()
		add_child(go)
		go.setup_results(summary)

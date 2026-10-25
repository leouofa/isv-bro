# scripts/GameWorld.gd
extends Node3D

@export var sector_id: int = 1
@export var total_anomalies: int = 8

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

var spawn_timer: float = 0.0
var hazard_timer: float = 0.0

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

func _ready() -> void:
	if has_node("/root/GameManager"):
		sector_id = get_node("/root/GameManager").current_sector
		get_node("/root/GameManager").start_new_run(sector_id)
		get_node("/root/GameManager").run_ended.connect(_on_run_ended)

	if has_node("/root/MusicManager"):
		get_node("/root/MusicManager").play_sector_music(sector_id, 0)

	setup_tunnel()
	if laser_mesh:
		laser_mesh.visible = false

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

	# Wave Spawning
	if not is_boss_active:
		spawn_timer += delta
		hazard_timer += delta

		if spawn_timer >= 3.8 and anomalies_spawned < total_anomalies:
			spawn_timer = 0.0
			spawn_anomaly()

		if hazard_timer >= 6.5 and anomalies_spawned < total_anomalies:
			hazard_timer = 0.0
			spawn_hazard_or_pickup()

		if anomalies_cleared >= total_anomalies and not is_boss_active:
			spawn_boss()

	# Lock-on Targeting
	update_lock_on_target()

	# Project reticle to HUD
	if hud and hud.has_method("update_reticle_projection"):
		hud.update_reticle_projection(camera, locked_target)

	# Handle root salvo key inputs (1-4, Q-E-R-F)
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
		if boss_instance.has_method("get") and boss_instance.prompt_data:
			current_prompt = boss_instance.prompt_data
			if hud and hud.has_method("display_prompt"):
				hud.display_prompt(current_prompt)
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
	if locked_target == null:
		return

	# SFX and visual laser beam
	if has_node("/root/SoundEffects"):
		get_node("/root/SoundEffects").play_laser_salvo()

	draw_laser_beam(player_jet.global_position, locked_target.global_position)

	var correct_idx: int = int(current_prompt.get("correct_index", -1))
	var target_id: String = current_prompt.get("target_id", "")

	if selected_index == correct_idx:
		# Hit!
		if has_node("/root/GameManager"):
			var pts: int = get_node("/root/GameManager").register_root_hit(target_id)
			if pts > 200:
				if has_node("/root/SoundEffects"):
					get_node("/root/SoundEffects").play_combo_up(get_node("/root/GameManager").combo_multiplier)
			if get_node("/root/GameManager").combo_multiplier >= 8:
				get_node("/root/GameManager").bro_callout.emit("HYPE_COMBO", "RADICAL 8X ETYMOLOGY, BRO!!")

		if is_boss_active and locked_target == boss_instance:
			boss_instance.register_hit()
		else:
			anomalies_cleared += 1
			locked_target.detonate()
			locked_target = null
	else:
		# Miss!
		if has_node("/root/SoundEffects"):
			get_node("/root/SoundEffects").play_error_buzz()
		if has_node("/root/GameManager"):
			get_node("/root/GameManager").register_root_miss(target_id)
		shake_camera()

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
	if ANOMALY_SCENE == null:
		return
	anomalies_spawned += 1
	var anom := ANOMALY_SCENE.instantiate() as Node3D
	var spawn_x := randf_range(-4.5, 4.5)
	var spawn_y := randf_range(-2.5, 2.5)
	anom.position = Vector3(spawn_x, spawn_y, -55.0)

	var target_root := {}
	if has_node("/root/LexiconManager"):
		target_root = get_node("/root/LexiconManager").select_weighted_root(sector_id)

	objects_container.add_child(anom)
	anom.setup(target_root, sector_id)
	active_anomalies.append(anom)
	anom.destroyed.connect(_on_anomaly_destroyed)

func _on_anomaly_destroyed(anom: Node3D) -> void:
	active_anomalies.erase(anom)
	if locked_target == anom:
		locked_target = null

func spawn_hazard_or_pickup() -> void:
	var roll := randf()
	if roll < 0.5 and HAZARD_GATE:
		# Laser gate hazard
		var gate := Area3D.new()
		gate.add_to_group("hazards")
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
		objects_container.add_child(gate)

		# Move along rail
		var tw := create_tween()
		tw.tween_property(gate, "position:z", 10.0, 3.5)
		tw.tween_callback(gate.queue_free)
	elif roll < 0.75 and PICKUP_COOLANT:
		# Coolant cell pickup
		var cell := Area3D.new()
		cell.add_to_group("pickup_coolant")
		var model: Node3D = PICKUP_COOLANT.instantiate()
		cell.add_child(model)
		var shape := CollisionShape3D.new()
		var sp := SphereShape3D.new()
		sp.radius = 1.0
		shape.shape = sp
		cell.add_child(shape)
		cell.position = Vector3(randf_range(-4.0, 4.0), randf_range(-2.0, 2.0), -55.0)
		objects_container.add_child(cell)

		var tw := create_tween()
		tw.tween_property(cell, "position:z", 10.0, 3.8)
		tw.tween_callback(cell.queue_free)
	elif PICKUP_SHIELD:
		# Shield orb pickup
		var orb := Area3D.new()
		orb.add_to_group("pickup_shield")
		var model: Node3D = PICKUP_SHIELD.instantiate()
		orb.add_child(model)
		var shape := CollisionShape3D.new()
		var sp := SphereShape3D.new()
		sp.radius = 1.0
		shape.shape = sp
		orb.add_child(shape)
		orb.position = Vector3(randf_range(-4.0, 4.0), randf_range(-2.0, 2.0), -55.0)
		objects_container.add_child(orb)

		var tw := create_tween()
		tw.tween_property(orb, "position:z", 10.0, 3.8)
		tw.tween_callback(orb.queue_free)

func spawn_boss() -> void:
	if BOSS_SCENE == null:
		return
	is_boss_active = true
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").bro_callout.emit("BOSS_ALERT", "FINAL EXAM BOSS APPROACHING! SYNTHESIZE COMPOUND ROOTS!")

	boss_instance = BOSS_SCENE.instantiate() as Node3D
	boss_instance.position = Vector3(0, 1.0, -28.0)
	objects_container.add_child(boss_instance)
	boss_instance.setup_boss(sector_id)
	boss_instance.boss_defeated.connect(_on_boss_defeated)

func _on_boss_defeated() -> void:
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").finalize_run(true)

func _on_run_ended(_summary: Dictionary) -> void:
	pass

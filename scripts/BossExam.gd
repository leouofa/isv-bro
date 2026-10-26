# scripts/BossExam.gd
extends Area3D

signal boss_defeated()
signal phase_advanced(current_phase: int, total_phases: int, term: String, root_needed: String)
signal boss_hp_changed(current_hp: float, max_hp: float)

var sector_id: int = 1
var boss_data: Dictionary = {}
var compounds: Array = []
var compound_idx: int = 0
var sequence_idx: int = 0

var current_target_root_id: String = ""
var prompt_data: Dictionary = {}
var is_active: bool = false
var is_defeated: bool = false
var attack_timer: float = 0.0
var attack_interval: float = 1.8

var boss_max_hp: float = 600.0
var boss_hp: float = 600.0

@onready var label_name: Label3D = $BossLabels/NameLabel
@onready var label_clue: Label3D = $BossLabels/ClueLabel
@onready var label_synthesis: Label3D = $BossLabels/SynthesisLabel
@onready var core_mesh: Node3D = $boss_core

func _ready() -> void:
	add_to_group("boss")

func setup_boss(sector: int) -> void:
	sector_id = sector
	is_active = true
	is_defeated = false
	compound_idx = 0
	sequence_idx = 0
	boss_max_hp = 500.0 + (sector * 100.0)
	boss_hp = boss_max_hp
	attack_timer = 0.0

	if is_inside_tree() and has_node("/root/LexiconManager"):
		boss_data = get_node("/root/LexiconManager").get_boss_exam(sector_id)
		compounds = boss_data.get("compounds", [])

	if label_name:
		label_name.text = boss_data.get("boss_name", "ANOMALY OVERLORD")

	if label_clue:
		label_clue.text = "[ SPACE: FIRE LASER | WASD: DODGE ATTACKS ]"

	_update_hp_display()

	if is_inside_tree() and has_node("/root/MusicManager"):
		get_node("/root/MusicManager").play_boss_music(0)

	boss_hp_changed.emit(boss_hp, boss_max_hp)

func _update_hp_display() -> void:
	if label_synthesis:
		var pct := int((boss_hp / boss_max_hp) * 100.0)
		label_synthesis.text = "CORE INTEGRITY: %d%%" % pct
		if pct > 50:
			label_synthesis.modulate = Color("#39FF14")
		elif pct > 25:
			label_synthesis.modulate = Color("#FFE600")
		else:
			label_synthesis.modulate = Color("#FF007F")

func take_laser_damage(amount: float) -> void:
	if not is_active or is_defeated:
		return

	boss_hp = max(0.0, boss_hp - amount)
	boss_hp_changed.emit(boss_hp, boss_max_hp)
	_update_hp_display()

	# Visual flash on hit
	if core_mesh:
		var tw := create_tween()
		tw.tween_property(core_mesh, "scale", Vector3(1.15, 1.15, 1.15), 0.05)
		tw.tween_property(core_mesh, "scale", Vector3(1.0, 1.0, 1.0), 0.08)

	if boss_hp <= 0.0:
		defeat_boss()

func register_hit() -> void:
	# Fallback/compatibility method for test suite or external calls
	take_laser_damage(boss_max_hp / 4.0)

func defeat_boss() -> void:
	if is_defeated:
		return
	is_defeated = true
	is_active = false
	if is_inside_tree() and has_node("/root/GameManager"):
		get_node("/root/GameManager").score += 10000
		get_node("/root/GameManager").bro_callout.emit("HYPE_COMBO", "FINAL EXAM PASSED! 10,000 PTS BONUS, BRO!!")

	boss_defeated.emit()

	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3(0.01, 0.01, 0.01), 1.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)

func _physics_process(delta: float) -> void:
	if not is_active or is_defeated:
		return

	# Boss pacing and gentle floating
	position.x = sin(Time.get_ticks_msec() * 0.001) * 3.5
	position.y = 1.0 + cos(Time.get_ticks_msec() * 0.0008) * 1.5

	if core_mesh:
		core_mesh.rotate_y(0.7 * delta)
		core_mesh.rotate_z(0.3 * delta)

	# Launch boss attack patterns
	attack_timer += delta
	if attack_timer >= attack_interval:
		attack_timer = 0.0
		attack_interval = randf_range(1.5, 2.2)
		launch_boss_attack()

func launch_boss_attack() -> void:
	var container := get_parent()
	if container == null:
		return

	var pattern := randi() % 3
	match pattern:
		0:
			# Triple Plasma Orbs spread across lane
			for offset_x in [-2.5, 0.0, 2.5]:
				_spawn_plasma_orb(container, Vector3(position.x + offset_x, position.y + randf_range(-0.5, 0.5), position.z + 1.0), 2.8)
		1:
			# Sweeping Laser Bar across corridor
			_spawn_laser_gate(container, Vector3(randf_range(-2.0, 2.0), randf_range(-1.5, 1.5), position.z + 1.0))
		2:
			# Dual Targeted Plasma Burst
			for i in range(2):
				var target_x := randf_range(-4.0, 4.0)
				var target_y := randf_range(-2.5, 2.5)
				_spawn_plasma_orb(container, Vector3(target_x, target_y, position.z + 1.0), 2.2)

func _spawn_plasma_orb(container: Node, spawn_pos: Vector3, travel_time: float) -> void:
	var orb := Area3D.new()
	orb.add_to_group("hazards")

	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.8
	shape.shape = sphere
	orb.add_child(shape)

	var mesh_inst := MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = 0.8
	sphere_mesh.height = 1.6
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#FF007F")
	mat.emission_enabled = true
	mat.emission = Color("#FF007F")
	mat.emission_energy_multiplier = 3.0
	sphere_mesh.material = mat
	mesh_inst.mesh = sphere_mesh
	orb.add_child(mesh_inst)

	orb.position = spawn_pos
	container.add_child(orb)

	var tw := orb.create_tween()
	tw.tween_property(orb, "position:z", 10.0, travel_time)
	tw.tween_callback(orb.queue_free)

func _spawn_laser_gate(container: Node, spawn_pos: Vector3) -> void:
	var gate := Area3D.new()
	gate.add_to_group("hazards")

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(4.0, 0.7, 0.7)
	shape.shape = box
	gate.add_child(shape)

	var mesh_inst := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(4.0, 0.7, 0.7)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#FFE600")
	mat.emission_enabled = true
	mat.emission = Color("#FFE600")
	mat.emission_energy_multiplier = 2.5
	box_mesh.material = mat
	mesh_inst.mesh = box_mesh
	gate.add_child(mesh_inst)

	gate.position = spawn_pos
	container.add_child(gate)

	var tw := gate.create_tween()
	tw.tween_property(gate, "position:z", 10.0, 2.5)
	tw.tween_callback(gate.queue_free)

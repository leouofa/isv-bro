# scripts/BossExam.gd
extends Area3D

signal boss_defeated()
signal phase_advanced(current_phase: int, total_phases: int, term: String, root_needed: String)

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

	if has_node("/root/LexiconManager"):
		boss_data = get_node("/root/LexiconManager").get_boss_exam(sector_id)
		compounds = boss_data.get("compounds", [])

	if label_name:
		label_name.text = boss_data.get("boss_name", "ANOMALY OVERLORD")

	if has_node("/root/MusicManager"):
		get_node("/root/MusicManager").play_boss_music(0)

	_setup_current_target()

func _setup_current_target() -> void:
	if compound_idx >= compounds.size():
		defeat_boss()
		return

	var current_compound: Dictionary = compounds[compound_idx]
	var seq: Array = current_compound.get("sequence", [])
	if sequence_idx >= seq.size():
		compound_idx += 1
		sequence_idx = 0
		_setup_current_target()
		return

	current_target_root_id = seq[sequence_idx]
	if has_node("/root/LexiconManager"):
		prompt_data = get_node("/root/LexiconManager").build_multiple_choice_prompt(current_target_root_id, 4)

	# Update 3D labels
	var term: String = current_compound.get("term", "")
	var clue: String = current_compound.get("clue", "")
	if label_clue:
		label_clue.text = "[ " + clue.to_upper() + " ]"
	if label_synthesis:
		var synth_str := ""
		for i in range(seq.size()):
			if i < sequence_idx:
				synth_str += "[" + seq[i].to_upper() + "] "
			elif i == sequence_idx:
				synth_str += "[ ??? ] "
			else:
				synth_str += "[ ... ] "
		label_synthesis.text = "SYNTHESIS: " + synth_str

	phase_advanced.emit(compound_idx + 1, compounds.size(), term, current_target_root_id)

func register_hit() -> void:
	sequence_idx += 1
	var current_compound: Dictionary = compounds[compound_idx]
	var seq: Array = current_compound.get("sequence", [])
	if sequence_idx >= seq.size():
		compound_idx += 1
		sequence_idx = 0

	if compound_idx >= compounds.size():
		defeat_boss()
	else:
		_setup_current_target()

func defeat_boss() -> void:
	if is_defeated:
		return
	is_defeated = true
	is_active = false
	if has_node("/root/GameManager"):
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

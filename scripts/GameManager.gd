# scripts/GameManager.gd
extends Node

signal score_changed(new_score: int, combo: int)
signal shield_changed(current_hp: float, max_hp: float)
signal overheat_changed(current_heat: float, is_locked_out: bool)
signal bro_callout(state: String, message: String)
signal run_ended(summary: Dictionary)

const SAVE_PATH := "user://isv_save.json"

var current_sector: int = 1
var score: int = 0
var combo_multiplier: int = 1
var streak_count: int = 0
var max_combo_this_run: int = 1
var shield_hp: float = 100.0
var max_shield_hp: float = 100.0
var cognitive_overheat: float = 0.0
var is_overheated_lockout: bool = false
var lockout_timer: float = 0.0
var shots_fired: int = 0
var shots_hit: int = 0

var save_data: Dictionary = {
	"sector_scores": {"1": 0, "2": 0, "3": 0, "4": 0},
	"sector_grades": {"1": "-", "2": "-", "3": "-", "4": "-"},
	"unlocked_roots": {},
	"root_stats": {}, # root_id -> {"hits": 0, "misses": 0}
	"total_runs": 0,
	"settings": {
		"master_volume": 1.0,
		"music_volume": 0.85,
		"sfx_volume": 0.9,
		"crt_scanlines": true
	}
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_save()

func _get_tree_safe() -> SceneTree:
	if is_inside_tree() and get_tree():
		return get_tree()
	var main_loop := Engine.get_main_loop()
	if main_loop is SceneTree:
		return main_loop as SceneTree
	return null

func _get_music_manager() -> Node:
	if is_inside_tree() and has_node("/root/MusicManager"):
		return get_node("/root/MusicManager")
	var tree := _get_tree_safe()
	if tree and tree.root and tree.root.has_node("MusicManager"):
		return tree.root.get_node("MusicManager")
	return null

func _get_lexicon_manager() -> Node:
	if is_inside_tree() and has_node("/root/LexiconManager"):
		return get_node("/root/LexiconManager")
	var tree := _get_tree_safe()
	if tree and tree.root and tree.root.has_node("LexiconManager"):
		return tree.root.get_node("LexiconManager")
	return null

func _process(delta: float) -> void:
	var tree := _get_tree_safe()
	if tree and tree.paused:
		return
	if is_overheated_lockout:
		lockout_timer -= delta
		cognitive_overheat = max(0.0, (lockout_timer / 3.5) * 100.0)
		overheat_changed.emit(cognitive_overheat, true)
		if lockout_timer <= 0.0:
			is_overheated_lockout = false
			cognitive_overheat = 0.0
			var mm := _get_music_manager()
			if mm and mm.has_method("set_low_pass_enabled"):
				mm.set_low_pass_enabled(false)
			overheat_changed.emit(cognitive_overheat, false)
			bro_callout.emit("IDLE", "COOLANT FLUSH COMPLETE! LASERS ONLINE, BRO!")
	else:
		if cognitive_overheat > 0.0:
			cognitive_overheat = max(0.0, cognitive_overheat - 4.0 * delta)
			overheat_changed.emit(cognitive_overheat, false)

func start_new_run(sector: int = 1) -> void:
	current_sector = clampi(sector, 1, 4)
	score = 0
	combo_multiplier = 1
	streak_count = 0
	max_combo_this_run = 1
	shield_hp = max_shield_hp
	cognitive_overheat = 0.0
	is_overheated_lockout = false
	lockout_timer = 0.0
	shots_fired = 0
	shots_hit = 0
	var mm := _get_music_manager()
	if mm and mm.has_method("set_low_pass_enabled"):
		mm.set_low_pass_enabled(false)

func register_root_hit(root_id: String, base_points: int = 200) -> int:
	shots_fired += 1
	shots_hit += 1
	streak_count += 1
	if streak_count >= 10:
		combo_multiplier = 8
	elif streak_count >= 6:
		combo_multiplier = 4
	elif streak_count >= 3:
		combo_multiplier = 2
	else:
		combo_multiplier = 1
	max_combo_this_run = max(max_combo_this_run, combo_multiplier)

	var points_earned := base_points * combo_multiplier
	score += points_earned
	cognitive_overheat = max(0.0, cognitive_overheat - 10.0)

	save_data["unlocked_roots"][root_id] = true
	var rstat: Dictionary = save_data["root_stats"].get(root_id, {"hits": 0, "misses": 0})
	rstat["hits"] = int(rstat.get("hits", 0)) + 1
	save_data["root_stats"][root_id] = rstat

	var lm := _get_lexicon_manager()
	if lm and lm.has_method("record_outcome"):
		lm.record_outcome(root_id, true)

	score_changed.emit(score, combo_multiplier)
	overheat_changed.emit(cognitive_overheat, is_overheated_lockout)
	return points_earned

func register_root_miss(expected_root_id: String) -> void:
	shots_fired += 1
	streak_count = 0
	combo_multiplier = 1
	cognitive_overheat = min(100.0, cognitive_overheat + 25.0)

	var rstat: Dictionary = save_data["root_stats"].get(expected_root_id, {"hits": 0, "misses": 0})
	rstat["misses"] = int(rstat.get("misses", 0)) + 1
	save_data["root_stats"][expected_root_id] = rstat

	var lm := _get_lexicon_manager()
	if lm and lm.has_method("record_outcome"):
		lm.record_outcome(expected_root_id, false)

	if cognitive_overheat >= 100.0 and not is_overheated_lockout:
		is_overheated_lockout = true
		lockout_timer = 3.5
		score = max(0, score - 300)
		var mm := _get_music_manager()
		if mm and mm.has_method("set_low_pass_enabled"):
			mm.set_low_pass_enabled(true)
		bro_callout.emit("OVERHEAT_ALARM", "COGNITIVE OVERHEAT 100%! WEAPONS LOCKED FOR 3.5s!")
	else:
		if lm and lm.has_method("get_mnemonic"):
			var tip: String = lm.get_mnemonic(expected_root_id)
			bro_callout.emit("MNEMONIC_TIP", tip)

	score_changed.emit(score, combo_multiplier)
	overheat_changed.emit(cognitive_overheat, is_overheated_lockout)

func apply_coolant(amount: float = 35.0) -> void:
	cognitive_overheat = max(0.0, cognitive_overheat - amount)
	if is_overheated_lockout and cognitive_overheat <= 25.0:
		is_overheated_lockout = false
		lockout_timer = 0.0
		var mm := _get_music_manager()
		if mm and mm.has_method("set_low_pass_enabled"):
			mm.set_low_pass_enabled(false)
	overheat_changed.emit(cognitive_overheat, is_overheated_lockout)
	bro_callout.emit("IDLE", "CRYO-COOLANT ABSORBED! CORE TEMP DROPPING!")

func apply_shield_damage(amount: float) -> void:
	shield_hp = max(0.0, shield_hp - amount)
	streak_count = 0
	combo_multiplier = 1
	score_changed.emit(score, combo_multiplier)
	shield_changed.emit(shield_hp, max_shield_hp)
	if shield_hp <= 0.0:
		finalize_run(false)

func restore_shield(amount: float) -> void:
	shield_hp = min(max_shield_hp, shield_hp + amount)
	shield_changed.emit(shield_hp, max_shield_hp)

func calculate_grade(accuracy: float, survived: bool) -> String:
	if not survived:
		return "D" if accuracy < 0.65 else "C"
	if accuracy >= 0.92:
		return "S"
	elif accuracy >= 0.80:
		return "A"
	elif accuracy >= 0.65:
		return "B"
	elif accuracy >= 0.50:
		return "C"
	return "D"

func finalize_run(survived: bool) -> Dictionary:
	var accuracy := 1.0 if shots_fired == 0 else float(shots_hit) / float(shots_fired)
	var grade := calculate_grade(accuracy, survived)
	var sec_key := str(current_sector)
	var prev_best := int(save_data["sector_scores"].get(sec_key, 0))
	var is_new_record := score > prev_best
	if is_new_record:
		save_data["sector_scores"][sec_key] = score

	var rank_order := {"-": 0, "D": 1, "C": 2, "B": 3, "A": 4, "S": 5}
	var prev_grade: String = save_data["sector_grades"].get(sec_key, "-")
	if rank_order.get(grade, 0) > rank_order.get(prev_grade, 0):
		save_data["sector_grades"][sec_key] = grade

	save_data["total_runs"] = int(save_data.get("total_runs", 0)) + 1
	save_to_disk()

	var summary := {
		"sector": current_sector,
		"score": score,
		"prev_high_score": prev_best,
		"is_new_high_score": is_new_record,
		"accuracy": accuracy,
		"grade": grade,
		"max_combo": max_combo_this_run,
		"survived": survived
	}
	run_ended.emit(summary)
	return summary

func save_to_disk() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))

func load_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var json := JSON.new()
			if json.parse(file.get_as_text()) == OK and json.data is Dictionary:
				for k in json.data.keys():
					save_data[k] = json.data[k]

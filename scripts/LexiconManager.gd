# scripts/LexiconManager.gd
extends Node

const LEXICON_PATH := "res://data/isv_lexicon.json"

var sectors: Array = []
var roots_by_id: Dictionary = {}
var roots_by_sector: Dictionary = {1: [], 2: [], 3: [], 4: []}
var boss_exams: Dictionary = {}
var weights: Dictionary = {} # root_id -> float (default 1.0)

func _init() -> void:
	load_lexicon()

func _ready() -> void:
	load_lexicon()

func load_lexicon() -> void:
	if not FileAccess.file_exists(LEXICON_PATH):
		push_error("Missing lexicon file: " + LEXICON_PATH)
		return
	var file := FileAccess.open(LEXICON_PATH, FileAccess.READ)
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK or not (json.data is Dictionary):
		push_error("Invalid JSON in lexicon file")
		return

	var data: Dictionary = json.data
	sectors = data.get("sectors", [])
	roots_by_id.clear()
	roots_by_sector = {1: [], 2: [], 3: [], 4: []}
	for entry in data.get("roots", []):
		var rid: String = entry["id"]
		var sec: int = int(entry.get("sector", 1))
		roots_by_id[rid] = entry
		if not roots_by_sector.has(sec):
			roots_by_sector[sec] = []
		roots_by_sector[sec].append(entry)
		if not weights.has(rid):
			weights[rid] = 1.0

	for boss in data.get("boss_exams", []):
		boss_exams[int(boss["sector"])] = boss

func record_outcome(root_id: String, hit: bool) -> void:
	var current_w: float = weights.get(root_id, 1.0)
	if hit:
		weights[root_id] = clampf(current_w - 0.2, 0.4, 8.0)
	else:
		weights[root_id] = clampf(current_w + 1.5, 0.4, 8.0)

func get_weight(root_id: String) -> float:
	return weights.get(root_id, 1.0)

func get_mnemonic(root_id: String) -> String:
	if roots_by_id.has(root_id):
		return roots_by_id[root_id].get("mnemonic", "Remember the root!")
	return "Check your Greek & Latin roots, bro!"

func select_weighted_root(sector_id: int) -> Dictionary:
	var pool: Array = roots_by_sector.get(sector_id, [])
	if pool.is_empty():
		pool = roots_by_id.values()
	var total_w := 0.0
	for item in pool:
		total_w += get_weight(item["id"])
	var roll := randf() * total_w
	var accum := 0.0
	for item in pool:
		accum += get_weight(item["id"])
		if roll <= accum:
			return item
	return pool[0]

func build_multiple_choice_prompt(target_root_id: String, count: int = 4) -> Dictionary:
	var target: Dictionary = roots_by_id.get(target_root_id, {})
	if target.is_empty():
		target = roots_by_id.values()[0]
		target_root_id = target["id"]

	var sec: int = int(target.get("sector", 1))
	var sector_pool: Array = roots_by_sector.get(sec, []).duplicate()
	sector_pool.shuffle()

	var options: Array[Dictionary] = [target]
	for candidate in sector_pool:
		if options.size() >= count:
			break
		if candidate["id"] != target_root_id:
			options.append(candidate)

	# Fallback to global pool if sector has fewer than count entries
	if options.size() < count:
		for candidate in roots_by_id.values():
			if options.size() >= count:
				break
			var exists := false
			for o in options:
				if o["id"] == candidate["id"]:
					exists = true
			if not exists:
				options.append(candidate)

	options.shuffle()
	var correct_idx := 0
	for i in range(options.size()):
		if options[i]["id"] == target_root_id:
			correct_idx = i
			break

	return {
		"target_id": target_root_id,
		"clue": target.get("meaning", ""),
		"origin": target.get("origin", ""),
		"mnemonic": target.get("mnemonic", ""),
		"options": options,
		"correct_index": correct_idx
	}

func get_boss_exam(sector_id: int) -> Dictionary:
	return boss_exams.get(sector_id, {})

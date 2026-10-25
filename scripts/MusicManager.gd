# scripts/MusicManager.gd
extends Node

const SECTOR_TRACKS := {
	0: ["res://tracks/Entryway.mp3", "res://tracks/Mirror Tech.mp3", "res://tracks/Understanding.mp3"],
	1: ["res://tracks/The Run.mp3", "res://tracks/Silly Verses.mp3"],
	2: ["res://tracks/Ultrabeat.mp3", "res://tracks/The Flight.mp3"],
	3: ["res://tracks/Undercurrent.mp3", "res://tracks/Low Cut.mp3"],
	4: ["res://tracks/Escape.mp3", "res://tracks/The Key.mp3", "res://tracks/Luck.mp3"],
	99: ["res://tracks/Left Turn.mp3", "res://tracks/Rerun.mp3", "res://tracks/The End.mp3"]
}

const TITLE_SECTOR_ID: int = -2

var audio_player: AudioStreamPlayer
var music_bus_idx: int = 0
var lpf_effect_idx: int = 0
var current_sector_played: int = -1
var current_track_path: String = ""
var all_tracks_cache: Array[String] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	setup_audio_bus()
	_ensure_player()

func setup_audio_bus() -> void:
	music_bus_idx = AudioServer.get_bus_index("Music")
	if music_bus_idx == -1:
		AudioServer.add_bus()
		music_bus_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(music_bus_idx, "Music")
		AudioServer.set_bus_send(music_bus_idx, "Master")

	# Check if LowPassFilter already exists on Music bus
	var has_lpf := false
	for i in range(AudioServer.get_bus_effect_count(music_bus_idx)):
		if AudioServer.get_bus_effect(music_bus_idx, i) is AudioEffectLowPassFilter:
			has_lpf = true
			lpf_effect_idx = i
			break

	if not has_lpf:
		var lpf := AudioEffectLowPassFilter.new()
		lpf.cutoff_hz = 850.0
		AudioServer.add_bus_effect(music_bus_idx, lpf)
		lpf_effect_idx = AudioServer.get_bus_effect_count(music_bus_idx) - 1

	AudioServer.set_bus_effect_enabled(music_bus_idx, lpf_effect_idx, false)

func set_low_pass_enabled(enabled: bool) -> void:
	if music_bus_idx >= 0 and lpf_effect_idx >= 0:
		AudioServer.set_bus_effect_enabled(music_bus_idx, lpf_effect_idx, enabled)

func get_all_tracks() -> Array[String]:
	if not all_tracks_cache.is_empty():
		return all_tracks_cache

	var tracks: Array[String] = []
	var dir := DirAccess.open("res://tracks")
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				var clean_name := file_name.trim_suffix(".import")
				if clean_name.ends_with(".mp3"):
					var full_path := "res://tracks/" + clean_name
					if not tracks.has(full_path):
						tracks.append(full_path)
			file_name = dir.get_next()
		dir.list_dir_end()

	if tracks.is_empty():
		tracks = [
			"res://tracks/Entryway.mp3",
			"res://tracks/Escape.mp3",
			"res://tracks/Left Turn.mp3",
			"res://tracks/Low Cut.mp3",
			"res://tracks/Luck.mp3",
			"res://tracks/Mirror Tech.mp3",
			"res://tracks/Rerun.mp3",
			"res://tracks/Silly Verses.mp3",
			"res://tracks/The End.mp3",
			"res://tracks/The Flight.mp3",
			"res://tracks/The Key.mp3",
			"res://tracks/The Run.mp3",
			"res://tracks/Ultrabeat.mp3",
			"res://tracks/Undercurrent.mp3",
			"res://tracks/Understanding.mp3"
		]

	all_tracks_cache = tracks
	return all_tracks_cache

func play_random_title_music() -> void:
	current_sector_played = TITLE_SECTOR_ID
	var tracks := get_all_tracks()
	if tracks.is_empty():
		return

	var candidates := tracks.duplicate()
	if candidates.size() > 1 and candidates.has(current_track_path):
		candidates.erase(current_track_path)

	var chosen: String = candidates.pick_random()
	current_track_path = ""
	play_track(chosen)

func play_sector_music(sector: int, track_index: int = 0) -> void:
	if not SECTOR_TRACKS.has(sector):
		sector = 0
	current_sector_played = sector
	var track_list: Array = SECTOR_TRACKS[sector]
	if track_list.is_empty():
		return
	var idx := track_index % track_list.size()
	play_track(track_list[idx])

func play_boss_music(boss_variant: int = 0) -> void:
	play_sector_music(99, boss_variant)

func _ensure_player() -> void:
	if audio_player == null:
		audio_player = AudioStreamPlayer.new()
		audio_player.bus = "Music"
		add_child(audio_player)
		if not audio_player.finished.is_connected(_on_track_finished):
			audio_player.finished.connect(_on_track_finished)

func play_track(path: String) -> void:
	_ensure_player()
	if current_track_path == path and audio_player.playing:
		return
	if not FileAccess.file_exists(path) and not ResourceLoader.exists(path):
		push_warning("Music track not found: " + path)
		return
	current_track_path = path
	var stream := load(path) as AudioStream
	if stream:
		audio_player.stream = stream
		if is_inside_tree() and audio_player.is_inside_tree():
			audio_player.play()

func stop_music() -> void:
	if audio_player:
		audio_player.stop()
	current_track_path = ""

func _on_track_finished() -> void:
	if current_sector_played == TITLE_SECTOR_ID:
		play_random_title_music()
		return

	# Loop within current category
	if current_sector_played != -1 and SECTOR_TRACKS.has(current_sector_played):
		var track_list: Array = SECTOR_TRACKS[current_sector_played]
		if not track_list.is_empty():
			var cur_idx := track_list.find(current_track_path)
			var next_idx := (cur_idx + 1) % track_list.size()
			play_track(track_list[next_idx])

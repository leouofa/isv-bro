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

var audio_player: AudioStreamPlayer
var music_bus_idx: int = 0
var lpf_effect_idx: int = 0
var current_sector_played: int = -1
var current_track_path: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	setup_audio_bus()
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = "Music"
	add_child(audio_player)
	audio_player.finished.connect(_on_track_finished)

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

func play_track(path: String) -> void:
	if current_track_path == path and audio_player.playing:
		return
	if not FileAccess.file_exists(path) and not ResourceLoader.exists(path):
		push_warning("Music track not found: " + path)
		return
	current_track_path = path
	var stream := load(path) as AudioStream
	if stream:
		audio_player.stream = stream
		audio_player.play()

func stop_music() -> void:
	audio_player.stop()
	current_track_path = ""

func _on_track_finished() -> void:
	# Loop within current category
	if current_sector_played != -1 and SECTOR_TRACKS.has(current_sector_played):
		var track_list: Array = SECTOR_TRACKS[current_sector_played]
		if not track_list.is_empty():
			var cur_idx := track_list.find(current_track_path)
			var next_idx := (cur_idx + 1) % track_list.size()
			play_track(track_list[next_idx])

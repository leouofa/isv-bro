# scripts/SoundEffects.gd
extends Node

const SAMPLE_RATE := 22050

var pool_size := 12
var player_pool: Array[AudioStreamPlayer] = []
var pool_idx := 0

var sfx_laser: AudioStreamWAV
var sfx_lock_on: AudioStreamWAV
var sfx_barrel_roll: AudioStreamWAV
var sfx_shield_hit: AudioStreamWAV
var sfx_error_buzz: AudioStreamWAV
var sfx_combo_up: AudioStreamWAV
var sfx_pickup: AudioStreamWAV
var sfx_ui_hover: AudioStreamWAV
var sfx_ui_click: AudioStreamWAV
var bro_chirps: Array[AudioStreamWAV] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	setup_audio_bus()
	generate_procedural_sounds()
	for i in range(pool_size):
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		player_pool.append(p)

func setup_audio_bus() -> void:
	var sfx_idx := AudioServer.get_bus_index("SFX")
	if sfx_idx == -1:
		AudioServer.add_bus()
		sfx_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(sfx_idx, "SFX")
		AudioServer.set_bus_send(sfx_idx, "Master")

func _get_player() -> AudioStreamPlayer:
	var p := player_pool[pool_idx]
	pool_idx = (pool_idx + 1) % pool_size
	return p

func play_sound(stream: AudioStreamWAV, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	if stream == null or not is_inside_tree():
		return
	var p := _get_player()
	if not p.is_inside_tree():
		return
	p.stream = stream
	p.volume_db = volume_db
	p.pitch_scale = pitch
	p.play()

# Public SFX triggers
func play_laser_salvo() -> void:
	play_sound(sfx_laser, -2.0, randf_range(0.95, 1.05))

func play_lock_on() -> void:
	play_sound(sfx_lock_on, -3.0, 1.0)

func play_barrel_roll() -> void:
	play_sound(sfx_barrel_roll, 0.0, randf_range(0.95, 1.05))

func play_shield_hit() -> void:
	play_sound(sfx_shield_hit, 2.0, randf_range(0.9, 1.1))

func play_error_buzz() -> void:
	play_sound(sfx_error_buzz, 1.0, 1.0)

func play_combo_up(combo_mult: int = 2) -> void:
	var pitch := 1.0 + (combo_mult * 0.1)
	play_sound(sfx_combo_up, 0.0, pitch)

func play_pickup() -> void:
	play_sound(sfx_pickup, 0.0, 1.0)

func play_ui_hover() -> void:
	play_sound(sfx_ui_hover, -14.0, randf_range(0.98, 1.04))

func play_ui_click() -> void:
	play_sound(sfx_ui_click, -8.0, randf_range(0.98, 1.02))

func play_bro_voice_cadence(syllables: int = 4) -> void:
	if bro_chirps.is_empty():
		return
	var count := clampi(syllables, 2, 7)
	for i in range(count):
		get_tree().create_timer(i * 0.06).timeout.connect(func():
			var chirp: AudioStreamWAV = bro_chirps.pick_random()
			play_sound(chirp, -4.0, randf_range(0.85, 1.25))
		)

# Procedural Sound Generators
func generate_procedural_sounds() -> void:
	sfx_laser = _gen_laser()
	sfx_lock_on = _gen_lock_on()
	sfx_barrel_roll = _gen_swoosh()
	sfx_shield_hit = _gen_crunch()
	sfx_error_buzz = _gen_buzz()
	sfx_combo_up = _gen_arpeggio()
	sfx_pickup = _gen_pickup()
	sfx_ui_hover = _gen_ui_hover()
	sfx_ui_click = _gen_ui_click()

	# Generate 4 Star Fox-style voice chirp variations
	for f in [340.0, 440.0, 520.0, 620.0]:
		bro_chirps.append(_gen_chirp(f))

func _create_wav(byte_data: PackedByteArray) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = byte_data
	return wav

func _gen_laser() -> AudioStreamWAV:
	var duration := 0.14
	var total_samples := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)

	var phase := 0.0
	for i in range(total_samples):
		var t := float(i) / float(total_samples)
		var freq := lerpf(1200.0, 140.0, t * t)
		phase += 2.0 * PI * freq / SAMPLE_RATE
		var env := 1.0 - t
		var wave := (fmod(phase, 2.0 * PI) / PI) - 1.0 # Sawtooth
		var sample := int(clampf(wave * env * 0.7, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, sample)

	return _create_wav(bytes)

func _gen_lock_on() -> AudioStreamWAV:
	var duration := 0.09
	var total_samples := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)

	var phase := 0.0
	for i in range(total_samples):
		var t := float(i) / float(total_samples)
		var freq := 1400.0 if t < 0.45 else 2100.0
		phase += 2.0 * PI * freq / SAMPLE_RATE
		var env := sin(t * PI)
		var wave := sin(phase)
		var sample := int(clampf(wave * env * 0.6, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, sample)

	return _create_wav(bytes)

func _gen_swoosh() -> AudioStreamWAV:
	var duration := 0.32
	var total_samples := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)

	var noise_filter := 0.0
	for i in range(total_samples):
		var t := float(i) / float(total_samples)
		var env := sin(t * PI)
		var white := randf_range(-1.0, 1.0)
		noise_filter = lerpf(noise_filter, white, 0.15)
		var sample := int(clampf(noise_filter * env * 0.8, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, sample)

	return _create_wav(bytes)

func _gen_crunch() -> AudioStreamWAV:
	var duration := 0.22
	var total_samples := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)

	var phase := 0.0
	for i in range(total_samples):
		var t := float(i) / float(total_samples)
		var env := exp(-10.0 * t)
		phase += 2.0 * PI * 85.0 / SAMPLE_RATE
		var rumble := sin(phase)
		var noise := randf_range(-0.8, 0.8)
		var mix := (rumble * 0.6 + noise * 0.5) * env
		var sample := int(clampf(mix, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, sample)

	return _create_wav(bytes)

func _gen_buzz() -> AudioStreamWAV:
	var duration := 0.25
	var total_samples := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)

	var phase := 0.0
	for i in range(total_samples):
		var t := float(i) / float(total_samples)
		phase += 2.0 * PI * 110.0 / SAMPLE_RATE
		var sq := 0.8 if sin(phase) > 0.0 else -0.8
		var env := 1.0 - t
		var sample := int(clampf(sq * env, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, sample)

	return _create_wav(bytes)

func _gen_arpeggio() -> AudioStreamWAV:
	var duration := 0.24
	var total_samples := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)

	var notes := [523.25, 659.25, 783.99, 1046.50] # C5, E5, G5, C6
	var samples_per_note := total_samples / notes.size()
	var phase := 0.0

	for i in range(total_samples):
		var note_idx := clampi(i / samples_per_note, 0, notes.size() - 1)
		var freq: float = notes[note_idx]
		phase += 2.0 * PI * freq / SAMPLE_RATE
		var note_t := float(i % samples_per_note) / float(samples_per_note)
		var env := 1.0 - note_t * 0.7
		var wave := sin(phase) + 0.3 * sin(2.0 * phase)
		var sample := int(clampf(wave * env * 0.5, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, sample)

	return _create_wav(bytes)

func _gen_pickup() -> AudioStreamWAV:
	var duration := 0.16
	var total_samples := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)

	var phase := 0.0
	for i in range(total_samples):
		var t := float(i) / float(total_samples)
		var freq := lerpf(660.0, 1320.0, t)
		phase += 2.0 * PI * freq / SAMPLE_RATE
		var env := sin(t * PI)
		var wave := sin(phase)
		var sample := int(clampf(wave * env * 0.6, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, sample)

	return _create_wav(bytes)

func _gen_chirp(base_freq: float) -> AudioStreamWAV:
	var duration := 0.045
	var total_samples := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)

	var phase := 0.0
	for i in range(total_samples):
		var t := float(i) / float(total_samples)
		var freq := base_freq + sin(t * PI * 4.0) * 50.0
		phase += 2.0 * PI * freq / SAMPLE_RATE
		var env := sin(t * PI)
		var wave := (absf(fmod(phase, 2.0 * PI) - PI) / PI) * 2.0 - 1.0 # Triangle
		var sample := int(clampf(wave * env * 0.6, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, sample)

	return _create_wav(bytes)

func _gen_ui_hover() -> AudioStreamWAV:
	# Crisp, high-tech synthwave blip
	var duration := 0.032
	var total_samples := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)

	var phase := 0.0
	for i in range(total_samples):
		var t := float(i) / float(total_samples)
		var freq := lerpf(1200.0, 1800.0, t)
		phase += 2.0 * PI * freq / SAMPLE_RATE
		var env := exp(-6.0 * t) * sin(t * PI)
		var wave := sin(phase) + 0.25 * sin(2.0 * phase)
		var sample := int(clampf(wave * env * 0.4, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, sample)

	return _create_wav(bytes)

func _gen_ui_click() -> AudioStreamWAV:
	# Resonant synth click
	var duration := 0.045
	var total_samples := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)

	var phase := 0.0
	for i in range(total_samples):
		var t := float(i) / float(total_samples)
		var freq := lerpf(880.0, 220.0, t * t)
		phase += 2.0 * PI * freq / SAMPLE_RATE
		var env := exp(-12.0 * t)
		var wave := (fmod(phase, 2.0 * PI) / PI) - 1.0 # Saw
		var sample := int(clampf(wave * env * 0.5, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, sample)

	return _create_wav(bytes)
